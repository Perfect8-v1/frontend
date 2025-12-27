// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import '../models/cart_models.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/api_exception.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onCartUpdated;

  const CartScreen({super.key, this.onCartUpdated});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _authService = AuthService();
  late final CartService _cartService;

  Cart? _cart;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cartService = CartService(_authService);
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cart = await _cartService.getCart();
      setState(() {
        _cart = cart;
        _isLoading = false;
      });
      // Update badge in navigation bar
      widget.onCartUpdated?.call();
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte hämta kundvagnen';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1) {
      _removeItem(item);
      return;
    }

    try {
      final cart = await _cartService.updateQuantity(item.productId, newQuantity);
      setState(() => _cart = cart);
      widget.onCartUpdated?.call();
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Kunde inte uppdatera antal');
    }
  }

  Future<void> _removeItem(CartItem item) async {
    try {
      final cart = await _cartService.removeItem(item.productId);
      setState(() => _cart = cart);
      widget.onCartUpdated?.call();
      _showMessage('${item.productName} borttagen');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Kunde inte ta bort produkten');
    }
  }

  Future<void> _clearCart() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Töm kundvagn?'),
        content: const Text('Är du säker på att du vill ta bort alla produkter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Töm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _cartService.clearCart();
      setState(() => _cart = Cart());
      widget.onCartUpdated?.call();
      _showMessage('Kundvagnen är tömd');
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Kunde inte tömma kundvagnen');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kundvagn'),
        actions: [
          if (_cart != null && !_cart!.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearCart,
              tooltip: 'Töm kundvagn',
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _cart != null && !_cart!.isEmpty
          ? _buildCheckoutBar()
          : null,
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
            Text(_errorMessage!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadCart,
              child: const Text('Försök igen'),
            ),
          ],
        ),
      );
    }

    if (_cart == null || _cart!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Din kundvagn är tom',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Lägg till produkter för att fortsätta',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fortsätt handla'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCart,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cart!.items.length,
        itemBuilder: (context, index) {
          return _CartItemCard(
            item: _cart!.items[index],
            onQuantityChanged: (qty) => _updateQuantity(_cart!.items[index], qty),
            onRemove: () => _removeItem(_cart!.items[index]),
          );
        },
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Totalt (${_cart!.itemCount} produkter)',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  _cart!.formattedTotal,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(cart: _cart!),
                    ),
                  ).then((_) => _loadCart()); // Reload cart when returning
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Till kassan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      ),
                    )
                  : _buildPlaceholder(),
            ),
            const SizedBox(width: 12),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.formattedUnitPrice,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quantity controls
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onPressed: () => onQuantityChanged(item.quantity - 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onPressed: () => onQuantityChanged(item.quantity + 1),
                      ),
                      const Spacer(),
                      Text(
                        item.formattedTotalPrice,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Remove button
            IconButton(
              icon: Icon(Icons.close, color: Colors.grey[500]),
              onPressed: onRemove,
              tooltip: 'Ta bort',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(Icons.image_outlined, color: Colors.grey[400]),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
