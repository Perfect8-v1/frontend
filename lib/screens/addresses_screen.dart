// lib/screens/addresses_screen.dart
import 'package:flutter/material.dart';
import '../models/customer_models.dart';
import '../services/customer_service.dart';
import '../services/auth_service.dart';
import '../services/api_exception.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _authService = AuthService();
  late final CustomerService _customerService;

  List<Address> _addresses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _customerService = CustomerService(_authService);
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final addresses = await _customerService.getAddresses();
      if (mounted) {
        setState(() {
          _addresses = addresses;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Kunde inte hämta adresser: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mina adresser'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Lägg till'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadAddresses,
              icon: const Icon(Icons.refresh),
              label: const Text('Försök igen'),
            ),
          ],
        ),
      );
    }

    if (_addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Inga adresser sparade',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Lägg till en leveransadress',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAddresses,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          final address = _addresses[index];
          return _buildAddressCard(address);
        },
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    final isDefault = address.defaultShipping || address.defaultBilling;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type badges
            Row(
              children: [
                if (address.recipientName != null)
                  Expanded(
                    child: Text(
                      address.recipientName!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                if (isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Standard',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Address lines
            if (address.streetAddress != null) Text(address.streetAddress!),
            if (address.addressLine2 != null &&
                address.addressLine2!.isNotEmpty)
              Text(address.addressLine2!),

            // City, postal code
            Text(
              '${address.postalCode ?? ''} ${address.city ?? ''}'.trim(),
            ),

            // Country
            if (address.country != null) Text(address.country!),

            // Phone
            if (address.phoneNumber != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    address.phoneNumber!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],

            // Actions
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditAddressDialog(address),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Redigera'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _confirmDeleteAddress(address),
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: Colors.red[700]),
                  label:
                      Text('Ta bort', style: TextStyle(color: Colors.red[700])),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog() {
    _showAddressFormDialog(null);
  }

  void _showEditAddressDialog(Address address) {
    _showAddressFormDialog(address);
  }

  void _showAddressFormDialog(Address? existingAddress) {
    final isEditing = existingAddress != null;
    final formKey = GlobalKey<FormState>();

    final recipientController =
        TextEditingController(text: existingAddress?.recipientName ?? '');
    final streetController =
        TextEditingController(text: existingAddress?.streetAddress ?? '');
    final postalCodeController =
        TextEditingController(text: existingAddress?.postalCode ?? '');
    final cityController =
        TextEditingController(text: existingAddress?.city ?? '');
    final phoneController =
        TextEditingController(text: existingAddress?.phoneNumber ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEditing ? 'Redigera adress' : 'Lägg till adress'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: recipientController,
                  decoration: const InputDecoration(
                    labelText: 'Mottagare *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Obligatoriskt' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: streetController,
                  decoration: const InputDecoration(
                    labelText: 'Gatuadress *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Obligatoriskt' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: postalCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Postnr *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Obligatoriskt' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: cityController,
                        decoration: const InputDecoration(
                          labelText: 'Ort *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Obligatoriskt' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v?.isEmpty ?? true ? 'Obligatoriskt' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              Navigator.pop(dialogContext);

              final addressData = {
                'recipientName': recipientController.text,
                'streetAddress': streetController.text,
                'postalCode': postalCodeController.text,
                'city': cityController.text,
                'phoneNumber': phoneController.text,
                'country': 'Sverige',
                'countryCode': 'SE',
                'addressType': 'BOTH',
                'defaultShipping': _addresses.isEmpty,
                'defaultBilling': _addresses.isEmpty,
              };

              try {
                await _customerService.addAddress(addressData);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Adress sparad')),
                  );
                  _loadAddresses();
                }
              } on ApiException catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fel: ${e.message}')),
                  );
                }
              }
            },
            child: const Text('Spara'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAddress(Address address) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ta bort adress?'),
        content: Text(
          'Vill du ta bort adressen "${address.streetAddress}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              if (address.addressId == null) return;

              try {
                await _customerService.deleteAddress(address.addressId!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Adress borttagen')),
                  );
                  _loadAddresses();
                }
              } on ApiException catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fel: ${e.message}')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Ta bort'),
          ),
        ],
      ),
    );
  }
}
