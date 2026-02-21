// lib/screens/admin_upload_screen.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'admin_product_images_screen.dart';
import '../services/auth_service.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  final _authService = AuthService();
  final _picker = ImagePicker();

  XFile? _selectedFile;
  Uint8List? _selectedBytes;
  String _category = 'products';
  bool _isUploading = false;
  String? _uploadResult;
  final List<String> _uploadedImages = [];

  final _categories = ['products', 'categories', 'blog', 'avatars', 'banners'];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedFile = image;
        _selectedBytes = bytes;
        _uploadResult = null;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedFile == null || _selectedBytes == null) return;

    setState(() {
      _isUploading = true;
      _uploadResult = null;
    });

    try {
      final uri = Uri.parse('${ApiConfig.imageUrl}/api/images/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add auth header
      request.headers['Authorization'] = 'Bearer ${_authService.token}';

      // Add file from bytes (works on Web + native)
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        _selectedBytes!,
        filename: _selectedFile!.name,
      ));

      // Add category
      request.fields['category'] = _category;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _uploadResult = 'Uppladdning lyckades!';
          _uploadedImages.insert(
              0, data['originalUrl'] ?? data['thumbnailUrl'] ?? '');
          _selectedFile = null;
          _selectedBytes = null;
        });
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          _uploadResult = 'Fel: ${error['message'] ?? response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _uploadResult = 'Fel: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ladda upp Bilder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Koppla bilder till produkter',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminProductImagesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategori',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _category = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Image preview / picker
            Card(
              child: InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _selectedBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tryck för att välja bild',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Upload button
            FilledButton.icon(
              onPressed:
                  _selectedFile != null && !_isUploading ? _uploadImage : null,
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(_isUploading ? 'Laddar upp...' : 'Ladda upp'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            // Result message
            if (_uploadResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _uploadResult!.startsWith('Fel')
                      ? Colors.red[50]
                      : Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _uploadResult!,
                  style: TextStyle(
                    color: _uploadResult!.startsWith('Fel')
                        ? Colors.red[700]
                        : Colors.green[700],
                  ),
                ),
              ),
            ],

            // Recently uploaded
            if (_uploadedImages.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Nyligen uppladdade',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _uploadedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _uploadedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
