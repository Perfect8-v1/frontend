// lib/screens/admin_product_edit_screen.dart
import 'package:flutter/material.dart';
import '../models/product_models.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/api_exception.dart';

/// Admin screen for creating/editing products
class AdminProductEditScreen extends StatefulWidget {
  final Product? product; // null = create new, otherwise edit

  const AdminProductEditScreen({super.key, this.product});

  @override
  State<AdminProductEditScreen> createState() => _AdminProductEditScreenState();
}

class _AdminProductEditScreenState extends State<AdminProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  late ProductService _productService;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<Category> _categories = [];

  // Form controllers - Grundinfo
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _barcodeController = TextEditingController();

  // Prissättning
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();

  // Lager
  final _stockQuantityController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();
  final _reorderPointController = TextEditingController();
  final _reorderQuantityController = TextEditingController();

  // Egenskaper
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _colorController = TextEditingController();
  final _sizeController = TextEditingController();
  final _materialController = TextEditingController();

  // SEO
  final _metaTitleController = TextEditingController();
  final _metaDescriptionController = TextEditingController();
  final _metaKeywordsController = TextEditingController();

  // Taggar
  final _tagsController = TextEditingController();

  // Status
  bool _featured = false;
  bool _active = true;

  // Kategori
  int? _selectedCategoryId;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _productService = ProductService(_authService);
    _loadCategories();
    _populateForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockQuantityController.dispose();
    _lowStockThresholdController.dispose();
    _reorderPointController.dispose();
    _reorderQuantityController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _materialController.dispose();
    _metaTitleController.dispose();
    _metaDescriptionController.dispose();
    _metaKeywordsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _populateForm() {
    final product = widget.product;
    if (product == null) return;

    _nameController.text = product.name;
    _skuController.text = product.sku ?? '';
    _descriptionController.text = product.description ?? '';
    _brandController.text = product.brand ?? '';
    _manufacturerController.text = product.manufacturer ?? '';
    _modelController.text = product.model ?? '';
    _barcodeController.text = product.barcode ?? '';
    _priceController.text = product.price.toString();
    _discountPriceController.text = product.discountPrice?.toString() ?? '';
    _stockQuantityController.text = product.stockQuantity.toString();
    _lowStockThresholdController.text = product.lowStockThreshold?.toString() ?? '';
    _reorderPointController.text = product.reorderPoint?.toString() ?? '';
    _reorderQuantityController.text = product.reorderQuantity?.toString() ?? '';
    _weightController.text = product.weight?.toString() ?? '';
    _dimensionsController.text = product.dimensions ?? '';
    _colorController.text = product.color ?? '';
    _sizeController.text = product.size ?? '';
    _materialController.text = product.material ?? '';
    _metaTitleController.text = product.metaTitle ?? '';
    _metaDescriptionController.text = product.metaDescription ?? '';
    _metaKeywordsController.text = product.metaKeywords ?? '';
    _tagsController.text = product.tags.join(', ');
    _featured = product.featured;
    _active = product.active;
    _selectedCategoryId = product.categoryId;
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    try {
      final categories = await _productService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte ladda kategorier';
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Build product data
      final productData = {
        'name': _nameController.text.trim(),
        'sku': _skuController.text.trim(),
        'description': _descriptionController.text.trim(),
        'brand': _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        'manufacturer': _manufacturerController.text.trim().isEmpty ? null : _manufacturerController.text.trim(),
        'model': _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
        'barcode': _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'discountPrice': _discountPriceController.text.trim().isEmpty
            ? null
            : double.parse(_discountPriceController.text.trim()),
        'stockQuantity': int.parse(_stockQuantityController.text.trim()),
        'lowStockThreshold': _lowStockThresholdController.text.trim().isEmpty
            ? null
            : int.parse(_lowStockThresholdController.text.trim()),
        'reorderPoint': _reorderPointController.text.trim().isEmpty
            ? null
            : int.parse(_reorderPointController.text.trim()),
        'reorderQuantity': _reorderQuantityController.text.trim().isEmpty
            ? null
            : int.parse(_reorderQuantityController.text.trim()),
        'weight': _weightController.text.trim().isEmpty
            ? null
            : double.parse(_weightController.text.trim()),
        'dimensions': _dimensionsController.text.trim().isEmpty ? null : _dimensionsController.text.trim(),
        'color': _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
        'size': _sizeController.text.trim().isEmpty ? null : _sizeController.text.trim(),
        'material': _materialController.text.trim().isEmpty ? null : _materialController.text.trim(),
        'metaTitle': _metaTitleController.text.trim().isEmpty ? null : _metaTitleController.text.trim(),
        'metaDescription': _metaDescriptionController.text.trim().isEmpty ? null : _metaDescriptionController.text.trim(),
        'metaKeywords': _metaKeywordsController.text.trim().isEmpty ? null : _metaKeywordsController.text.trim(),
        'tags': _tagsController.text.trim().isEmpty
            ? []
            : _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
        'featured': _featured,
        'active': _active,
        'categoryId': _selectedCategoryId,
        'imageUrl': widget.product?.imageUrl,
        'galleryImages': widget.product?.galleryImages ?? [],
      };

      if (_isEditing) {
        await _productService.updateProduct(widget.product!.productId, productData);
      } else {
        await _productService.createProduct(productData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Produkt uppdaterad' : 'Produkt skapad'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
        title: Text(_isEditing ? 'Redigera Produkt' : 'Ny Produkt'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Spara', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
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
                    child: Text(_errorMessage!, style: TextStyle(color: Colors.red[700])),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Sektion 1: Grundinfo
          _buildSectionHeader('Grundinfo'),
          _buildTextField(_nameController, 'Produktnamn *', required: true),
          _buildTextField(_skuController, 'SKU *', required: true),
          _buildTextField(_descriptionController, 'Beskrivning', maxLines: 4),
          _buildTextField(_brandController, 'Varumärke'),
          _buildTextField(_manufacturerController, 'Tillverkare'),
          _buildTextField(_modelController, 'Modell'),
          _buildTextField(_barcodeController, 'Streckkod'),

          // Sektion 2: Prissättning
          _buildSectionHeader('Prissättning'),
          _buildTextField(_priceController, 'Pris *',
            required: true,
            keyboardType: TextInputType.number,
            suffix: 'kr',
          ),
          _buildTextField(_discountPriceController, 'Rabatterat pris',
            keyboardType: TextInputType.number,
            suffix: 'kr',
          ),

          // Sektion 3: Lager
          _buildSectionHeader('Lager'),
          _buildTextField(_stockQuantityController, 'Lagersaldo *',
            required: true,
            keyboardType: TextInputType.number,
            suffix: 'st',
          ),
          _buildTextField(_lowStockThresholdController, 'Lågt lager-gräns',
            keyboardType: TextInputType.number,
          ),
          _buildTextField(_reorderPointController, 'Beställningspunkt',
            keyboardType: TextInputType.number,
          ),
          _buildTextField(_reorderQuantityController, 'Beställningskvantitet',
            keyboardType: TextInputType.number,
          ),

          // Sektion 4: Egenskaper
          _buildSectionHeader('Egenskaper'),
          _buildTextField(_weightController, 'Vikt',
            keyboardType: TextInputType.number,
            suffix: 'kg',
          ),
          _buildTextField(_dimensionsController, 'Dimensioner',
            hint: 'T.ex. 10x20x5 cm',
          ),
          _buildTextField(_colorController, 'Färg'),
          _buildTextField(_sizeController, 'Storlek'),
          _buildTextField(_materialController, 'Material'),

          // Sektion 5: Kategorisering
          _buildSectionHeader('Kategorisering'),
          _buildCategoryDropdown(),
          _buildTextField(_tagsController, 'Taggar',
            hint: 'Separera med kommatecken',
          ),

          // Sektion 6: SEO
          _buildSectionHeader('SEO'),
          _buildTextField(_metaTitleController, 'Meta-titel',
            hint: 'För sökmotorer',
          ),
          _buildTextField(_metaDescriptionController, 'Meta-beskrivning',
            maxLines: 2,
          ),
          _buildTextField(_metaKeywordsController, 'Meta-nyckelord',
            hint: 'Separera med kommatecken',
          ),

          // Sektion 7: Status
          _buildSectionHeader('Status'),
          SwitchListTile(
            title: const Text('Aktiv'),
            subtitle: const Text('Produkten visas i butiken'),
            value: _active,
            onChanged: (value) => setState(() => _active = value),
          ),
          SwitchListTile(
            title: const Text('Utvald'),
            subtitle: const Text('Visas som utvald produkt'),
            value: _featured,
            onChanged: (value) => setState(() => _featured = value),
          ),

          // Sektion 8: Bilder
          if (_isEditing) ...[
            _buildSectionHeader('Bilder'),
            _buildImagePreview(),
          ],

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? suffix,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          suffixText: suffix,
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Detta fält är obligatoriskt';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    // Only use selected value if it exists in the loaded categories
    final validValue = _categories.any((c) => c.categoryId == _selectedCategoryId)
        ? _selectedCategoryId
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        value: validValue,
        decoration: const InputDecoration(
          labelText: 'Kategori *',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<int>(
            value: null,
            child: Text('Välj kategori...'),
          ),
          ..._categories.map((category) {
            return DropdownMenuItem<int>(
              value: category.categoryId,
              child: Text(category.name),
            );
          }),
        ],
        onChanged: (value) {
          setState(() => _selectedCategoryId = value);
        },
        validator: (value) {
          if (value == null) {
            return 'Välj en kategori';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImagePreview() {
    final imageUrl = widget.product?.largeImageUrl;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Huvudbild', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                ),
              )
            else
              _buildImagePlaceholder(),
            const SizedBox(height: 8),
            Text(
              'Använd "Produktbilder" i admin-menyn för att koppla bilder',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text('Ingen bild', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
