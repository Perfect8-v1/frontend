// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import '../models/cart_models.dart';
import '../models/order_models.dart';
import '../services/order_service.dart';
import '../services/cart_service.dart';
import '../services/customer_service.dart';
import '../services/api_exception.dart';
import '../services/auth_service.dart';
import '../services/pdf_service.dart';
import '../services/email_service.dart';
import '../models/customer_models.dart' as cm;

class CheckoutScreen extends StatefulWidget {
  final Cart cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  late final OrderService _orderService;
  late final CartService _cartService;
  late final CustomerService _customerService;
  late final EmailService _emailService;

  bool _isProcessing = false;
  bool _isLoadingProfile = true;
  String? _errorMessage;

  // Address fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _streetController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();

  // Payment method
  String _paymentMethod = 'INVOICE';

  // Track loaded address to avoid duplicates
  cm.Address? _loadedAddress;

  @override
  void initState() {
    super.initState();
    _orderService = OrderService(_authService);
    _cartService = CartService(_authService);
    _customerService = CustomerService(_authService);
    _emailService = EmailService(_authService);
    _loadCustomerProfile();
  }

  /// Load customer profile and pre-fill address fields
  Future<void> _loadCustomerProfile() async {
    try {
      final customer = await _customerService.getProfile();
      debugPrint('👤 Addresses count: ${customer.addresses.length}');
      debugPrint('👤 Default shipping: ${customer.defaultShippingAddress}');

      if (mounted) {
        setState(() {
          if (customer.firstName != null) {
            _firstNameController.text = customer.firstName!;
          }
          if (customer.lastName != null) {
            _lastNameController.text = customer.lastName!;
          }
          if (customer.phoneNumber != null) {
            _phoneController.text = customer.phoneNumber!;
          }

          final address = customer.defaultShippingAddress;
          if (address != null) {
            _loadedAddress = address;
            if (address.streetAddress != null) {
              _streetController.text = address.streetAddress!;
            }
            if (address.postalCode != null) {
              _postalCodeController.text = address.postalCode!;
            }
            if (address.city != null) {
              _cityController.text = address.city!;
            }
            if (_phoneController.text.isEmpty && address.phoneNumber != null) {
              _phoneController.text = address.phoneNumber!;
            }
          }

          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      debugPrint('👤 Could not load customer profile: $e');
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  /// Check if the address form has changed from what was loaded
  bool _addressChanged() {
    if (_loadedAddress == null) return true;
    return _streetController.text != (_loadedAddress!.streetAddress ?? '') ||
        _postalCodeController.text != (_loadedAddress!.postalCode ?? '') ||
        _cityController.text != (_loadedAddress!.city ?? '') ||
        _phoneController.text != (_loadedAddress!.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Steg 1: Spara adress BARA om den ändrats eller inte finns
      if (_addressChanged()) {
        debugPrint('📍 Address changed or new - saving...');
        await _customerService.addAddress({
          'addressType': 'SHIPPING',
          'recipientName':
              '${_firstNameController.text} ${_lastNameController.text}',
          'streetAddress': _streetController.text,
          'postalCode': _postalCodeController.text,
          'city': _cityController.text,
          'country': 'Sverige',
          'countryCode': 'SE',
          'phoneNumber': _phoneController.text,
          'defaultShipping': true,
        });
      } else {
        debugPrint('📍 Address unchanged - skipping save');
      }

      // Steg 2: Skapa order med adress
      final order = await _orderService.createOrder(
        cart: widget.cart,
        paymentMethod: _paymentMethod,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        street: _streetController.text,
        postalCode: _postalCodeController.text,
        city: _cityController.text,
        phone: _phoneController.text,
      );

      // Steg 3: Fyll i adress från formuläret om backend inte returnerade den
      final orderWithAddress = _ensureOrderAddress(order);

      // Clear cart
      await _cartService.clearCart();

      // Send confirmation email (fire and forget)
      final customerName =
          '${_firstNameController.text} ${_lastNameController.text}';
      final customerEmail = _authService.email ?? '';
      if (customerEmail.isNotEmpty) {
        _emailService
            .sendOrderConfirmation(
                orderWithAddress, customerEmail, customerName)
            .then((_) => debugPrint('📧 Orderbekräftelse skickad'))
            .catchError((e) => debugPrint('📧 Kunde inte skicka email: $e'));
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(
              order: orderWithAddress,
              emailSent: customerEmail.isNotEmpty,
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte skapa beställningen: $e';
        _isProcessing = false;
      });
    }
  }

  /// Fill order address from form if backend didn't return it
  Order _ensureOrderAddress(Order order) {
    if (order.shippingAddress.street.isNotEmpty) return order;

    debugPrint('📍 Order missing address - filling from form');
    final formAddress = Address(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      street: _streetController.text,
      postalCode: _postalCodeController.text,
      city: _cityController.text,
      country: 'Sverige',
      phone: _phoneController.text,
    );

    return Order(
      orderId: order.orderId,
      orderNumber: order.orderNumber,
      customerId: order.customerId,
      customerName: order.customerName,
      customerEmail: order.customerEmail,
      status: order.status,
      items: order.items,
      subtotal: order.subtotal,
      shipping: order.shipping,
      tax: order.tax,
      total: order.total,
      currency: order.currency,
      shippingAddress: formAddress,
      billingAddress: formAddress,
      paymentMethod: order.paymentMethod,
      paymentStatus: order.paymentStatus,
      trackingNumber: order.trackingNumber,
      trackingUrl: order.trackingUrl,
      notes: order.notes,
      createdDate: order.createdDate,
      shippedDate: order.shippedDate,
      deliveredDate: order.deliveredDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kassa'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                      child: Text(_errorMessage!,
                          style: TextStyle(color: Colors.red[700])),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            _buildSectionHeader('Din beställning'),
            _buildOrderSummary(),
            const SizedBox(height: 24),
            _buildSectionHeader('Leveransadress'),
            if (_isLoadingProfile)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              _buildAddressForm(),
            const SizedBox(height: 24),
            _buildSectionHeader('Betalningssätt'),
            _buildPaymentMethod(),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _isProcessing ? null : _placeOrder,
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Lägg beställning (${widget.cart.totalAmount.round()} kr)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ...widget.cart.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.productName} x${item.quantity}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text('${(item.unitPrice * item.quantity).round()} kr'),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Totalt',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${widget.cart.totalAmount.round()} kr',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Förnamn *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Obligatoriskt' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Efternamn *',
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
              controller: _streetController,
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
                  width: 120,
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Postnr *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Obligatoriskt' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
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
              controller: _phoneController,
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
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text('Faktura'),
            subtitle: const Text('Betala inom 14 dagar'),
            value: 'INVOICE',
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v!),
          ),
          RadioListTile<String>(
            title: const Text('Kort'),
            subtitle: const Text('Visa, Mastercard'),
            value: 'CARD',
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v!),
          ),
          RadioListTile<String>(
            title: const Text('Swish'),
            subtitle: const Text('Betala direkt'),
            value: 'SWISH',
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v!),
          ),
        ],
      ),
    );
  }
}

/// Order confirmation screen shown after successful order
class OrderConfirmationScreen extends StatefulWidget {
  final Order order;
  final bool emailSent;

  const OrderConfirmationScreen({
    super.key,
    required this.order,
    this.emailSent = false,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool _isPrintingInvoice = false;

  Future<void> _printInvoice() async {
    setState(() => _isPrintingInvoice = true);
    try {
      await PdfService.printInvoice(widget.order);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kunde inte skapa faktura: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrintingInvoice = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beställning mottagen'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tack för din beställning!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ordernummer: ${widget.order.orderNumber}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              if (widget.emailSent) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email_outlined,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Bekräftelse skickas till din e-post',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow('Status', _statusText(widget.order.status)),
                      const Divider(),
                      _buildInfoRow('Betalning', widget.order.paymentMethod),
                      const Divider(),
                      _buildInfoRow(
                          'Totalt', '${widget.order.total.round()} kr'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isPrintingInvoice ? null : _printInvoice,
                  icon: _isPrintingInvoice
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.print),
                  label: Text(_isPrintingInvoice
                      ? 'Skapar PDF...'
                      : 'Skriv ut / Spara faktura'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Tillbaka till butiken'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _statusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Väntar på betalning';
      case OrderStatus.processing:
        return 'Behandlas';
      case OrderStatus.shipped:
        return 'Skickad';
      case OrderStatus.delivered:
        return 'Levererad';
      case OrderStatus.cancelled:
        return 'Avbruten';
      case OrderStatus.refunded:
        return 'Återbetald';
    }
  }
}
