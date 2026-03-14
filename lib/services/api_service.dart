import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class ApiService {
  // Change this to your Railway deployment URL in production
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  bool get isAuthenticated => _token != null;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// Authenticate as admin and store the JWT token.
  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['token'] as String;
      setToken(token);
      return token;
    } else if (response.statusCode == 403) {
      throw Exception('Invalid username or password');
    } else {
      throw Exception('Login failed (${response.statusCode})');
    }
  }

  /// Fetch all blog posts.
  Future<List<Post>> fetchPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load posts (${response.statusCode})');
    }
  }

  /// Fetch a single blog post by ID.
  Future<Post> fetchPost(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      throw Exception('Post not found');
    } else {
      throw Exception('Failed to load post (${response.statusCode})');
    }
  }

  /// Create a new post (requires authentication).
  Future<Post> createPost(String title, String content) async {
    _requireAuth();
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: _headers,
      body: jsonEncode({'title': title, 'content': content}),
    );

    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create post (${response.statusCode})');
    }
  }

  /// Update an existing post (requires authentication).
  Future<Post> updatePost(int id, String title, String content) async {
    _requireAuth();
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$id'),
      headers: _headers,
      body: jsonEncode({'title': title, 'content': content}),
    );

    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      throw Exception('Post not found');
    } else {
      throw Exception('Failed to update post (${response.statusCode})');
    }
  }

  /// Delete a post by ID (requires authentication).
  Future<void> deletePost(int id) async {
    _requireAuth();
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$id'),
      headers: _headers,
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Post not found');
    } else {
      throw Exception('Failed to delete post (${response.statusCode})');
    }
  }

  void _requireAuth() {
    if (_token == null) {
      throw Exception('Authentication required');
    }
  }
}
