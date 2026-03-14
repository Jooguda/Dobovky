import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import 'post_detail_screen.dart';
import 'add_post_screen.dart';
import 'login_screen.dart';

class BlogListScreen extends StatefulWidget {
  final ApiService apiService;

  const BlogListScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final posts = await widget.apiService.fetchPosts();
      if (mounted) setState(() => _posts = posts);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePost(int id) async {
    try {
      await widget.apiService.deletePost(id);
      setState(() => _posts.removeWhere((p) => p.id == id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  void _openLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          apiService: widget.apiService,
          onLoginSuccess: () {
            Navigator.pop(context);
            setState(() {}); // Refresh to show admin actions
          },
        ),
      ),
    );
  }

  void _logout() {
    widget.apiService.clearToken();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.apiService.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dobovky'),
        actions: [
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin login',
              onPressed: _openLoginScreen,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadPosts,
          ),
        ],
      ),
      body: _buildBody(isAdmin),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddPostScreen(apiService: widget.apiService),
                  ),
                );
                if (created == true) _loadPosts();
              },
              tooltip: 'Add post',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(bool isAdmin) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPosts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.article_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No posts yet',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            if (isAdmin) ...[
              const SizedBox(height: 8),
              const Text('Tap + to create your first post',
                  style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _PostCard(
            post: post,
            isAdmin: isAdmin,
            onTap: () async {
              final changed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(
                    post: post,
                    apiService: widget.apiService,
                  ),
                ),
              );
              if (changed == true) _loadPosts();
            },
            onDelete: () => _showDeleteDialog(post),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(Post post) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text('Delete "${post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost(post.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PostCard({
    required this.post,
    required this.isAdmin,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          post.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          post.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isAdmin
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Delete',
                onPressed: onDelete,
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
