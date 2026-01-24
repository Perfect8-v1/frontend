// lib/screens/admin_blog_edit_screen.dart
import 'package:flutter/material.dart';
import '../models/blog_models.dart';
import '../services/blog_service.dart';
import '../services/auth_service.dart';
import '../services/api_exception.dart';

/// Admin screen for creating/editing blog posts
class AdminBlogEditScreen extends StatefulWidget {
  final BlogPost? post;

  const AdminBlogEditScreen({super.key, this.post});

  @override
  State<AdminBlogEditScreen> createState() => _AdminBlogEditScreenState();
}

class _AdminBlogEditScreenState extends State<AdminBlogEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  late final BlogService _blogService;

  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _contentController = TextEditingController();

  bool _published = false;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    _blogService = BlogService(_authService);

    if (_isEditing) {
      _titleController.text = widget.post!.title;
      _slugController.text = widget.post!.slug;
      _contentController.text = widget.post!.content;
      _published = widget.post!.published;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Generate slug from title
  String _generateSlug(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[åä]'), 'a')
        .replaceAll(RegExp(r'[ö]'), 'o')
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final request = BlogPostRequest(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        slug: _slugController.text.trim().isNotEmpty
            ? _slugController.text.trim()
            : null,
        published: _published,
      );

      if (_isEditing) {
        await _blogService.updatePost(widget.post!.postId, request);
      } else {
        await _blogService.createPost(request);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEditing ? 'Inlägget uppdaterades' : 'Inlägget skapades'),
          ),
        );
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte spara: $e';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Redigera inlägg' : 'Nytt inlägg'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Spara'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titel *',
                border: OutlineInputBorder(),
                hintText: 'Ange inläggets titel',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Titel krävs' : null,
              onChanged: (value) {
                // Auto-generate slug if empty
                if (_slugController.text.isEmpty) {
                  _slugController.text = _generateSlug(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Slug
            TextFormField(
              controller: _slugController,
              decoration: InputDecoration(
                labelText: 'Slug (URL)',
                border: const OutlineInputBorder(),
                hintText: 'Lämna tomt för automatisk generering',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Generera från titel',
                  onPressed: () {
                    _slugController.text = _generateSlug(_titleController.text);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Published switch
            SwitchListTile(
              title: const Text('Publicerad'),
              subtitle: Text(
                _published ? 'Synlig för alla' : 'Endast utkast',
              ),
              value: _published,
              onChanged: (v) => setState(() => _published = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Content
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Innehåll *',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                hintText: 'Skriv inläggets innehåll här...',
              ),
              maxLines: 15,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Innehåll krävs' : null,
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Sparar...' : 'Spara inlägg'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
