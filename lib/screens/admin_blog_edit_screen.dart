// lib/screens/admin_blog_edit_screen.dart
import 'dart:io';
import 'package:flutter/material.dart' hide ImageInfo;
import 'package:image_picker/image_picker.dart';
import '../models/blog_models.dart';
import '../services/blog_service.dart';
import '../services/image_service.dart';
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
  late final ImageService _imageService;

  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _contentController = TextEditingController();

  bool _published = false;
  bool _isSaving = false;
  String? _errorMessage;

  // Image state
  List<ImageInfo> _availableImages = [];
  List<BlogImage> _selectedImages = [];
  bool _isLoadingImages = false;

  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    _blogService = BlogService(_authService);
    _imageService = ImageService(_authService);

    if (_isEditing) {
      _titleController.text = widget.post!.title;
      _slugController.text = widget.post!.slug;
      _contentController.text = widget.post!.content;
      _published = widget.post!.published;
      _selectedImages = List.from(widget.post!.images);
    }

    _loadAvailableImages();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableImages() async {
    setState(() => _isLoadingImages = true);
    try {
      final blogImages = await _imageService.getImagesByCategory('blog').catchError((e) {
        debugPrint('Blog images error: $e');
        return <ImageInfo>[];
      });
      final productImages = await _imageService.getImagesByCategory('products').catchError((e) {
        debugPrint('Product images error: $e');
        return <ImageInfo>[];
      });
      debugPrint('Loaded ${blogImages.length} blog + ${productImages.length} product images');
      setState(() {
        _availableImages = [...blogImages, ...productImages];
        _isLoadingImages = false;
      });
    } catch (e) {
      debugPrint('Kunde inte ladda bilder: $e');
      setState(() => _isLoadingImages = false);
    }
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

  void _toggleImage(ImageInfo image) {
    setState(() {
      final existingIndex =
          _selectedImages.indexWhere((s) => s.imageId == image.imageId);
      if (existingIndex >= 0) {
        _selectedImages.removeAt(existingIndex);
      } else {
        _selectedImages.add(BlogImage(
          imageId: image.imageId!,
          displayOrder: _selectedImages.length,
        ));
      }
    });
  }

  bool _isImageSelected(ImageInfo image) {
    return _selectedImages.any((s) => s.imageId == image.imageId);
  }

  Future<void> _uploadBlogImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isLoadingImages = true);
    try {
      final file = File(picked.path);
      final uploaded = await _imageService.uploadImage(
        file,
        picked.name,
        category: 'blog',
      );
      // Auto-select the newly uploaded image
      setState(() {
        _availableImages.insert(0, uploaded);
        _selectedImages.add(BlogImage(
          imageId: uploaded.imageId!,
          displayOrder: _selectedImages.length,
        ));
        _isLoadingImages = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bilden laddades upp')),
        );
      }
    } catch (e) {
      setState(() => _isLoadingImages = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uppladdning misslyckades: $e')),
        );
      }
    }
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
        images: _selectedImages.isNotEmpty ? _selectedImages : null,
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
                    _slugController.text =
                        _generateSlug(_titleController.text);
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

            // Images section
            _buildImageSection(),
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

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Bilder',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(width: 8),
              Chip(
                label: Text('${_selectedImages.length} valda'),
                visualDensity: VisualDensity.compact,
              ),
            ],
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _isLoadingImages ? null : _uploadBlogImage,
              icon: const Icon(Icons.upload, size: 18),
              label: const Text('Ladda upp'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_isLoadingImages)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_availableImages.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Icon(Icons.image_not_supported, color: Colors.grey[400], size: 32),
                const SizedBox(height: 8),
                Text(
                  'Inga bilder uppladdade',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _loadAvailableImages,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Ladda om'),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _availableImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final image = _availableImages[index];
                final selected = _isImageSelected(image);
                return GestureDetector(
                  onTap: () => _toggleImage(image),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
                        width: selected ? 3 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            ImageService.getThumbnailUrl(image.imageId!, 'MEDIUM'),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                          if (selected)
                            Container(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              child: const Center(
                                child: Icon(Icons.check_circle, color: Colors.white, size: 32),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
