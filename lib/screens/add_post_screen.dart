import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';

class AddPostScreen extends StatefulWidget {
  final ApiService apiService;
  final Post? existingPost;

  const AddPostScreen({
    Key? key,
    required this.apiService,
    this.existingPost,
  }) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.existingPost != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingPost?.title ?? '');
    _contentController =
        TextEditingController(text: widget.existingPost?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isEditing) {
        await widget.apiService.updatePost(
          widget.existingPost!.id,
          _titleController.text.trim(),
          _contentController.text.trim(),
        );
      } else {
        await widget.apiService.createPost(
          _titleController.text.trim(),
          _contentController.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Post' : 'New Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Title is required'
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 12,
                textInputAction: TextInputAction.newline,
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Content is required'
                        : null,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Save Changes' : 'Publish Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
