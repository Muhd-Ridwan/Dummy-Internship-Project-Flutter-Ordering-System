import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:ordering_system/providers/auth_provider.dart';
import 'package:ordering_system/service/api_services.dart';
import 'package:ordering_system/providers/cart_providers.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _isLoading = true;
  bool _placing = false;
  String? _error;

  // Dropdown state
  String _payment = 'FPX Online Banking';
  String _shipping = 'Self Collection (RM2)';

  // Delivery fee derived from shipping choice
  double get _deliveryFee => _shipping.startsWith('Self') ? 2.0 : 5.0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ApiServices(baseUrl: ApiServices.defaultBaseUrl());
      final token = await api.readAccessToken();
      if (token == null) throw Exception('No Authenticated User');

      final me = await api.getMyProfile(token);

      // Prefill fields (only phone & address are editable)
      _nameCtrl.text = (me['name'] ?? '').toString();
      _addressCtrl.text = (me['address'] ?? '').toString();
      _phoneCtrl.text = (me['phoneNum'] ?? '').toString(); // <-- key from backend
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    final auth = context.read<AppAuthProvider>();

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is Empty')),
      );
      return;
    }
    if (_addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

    setState(() => _placing = true);
    try {
      final api = ApiServices(baseUrl: ApiServices.defaultBaseUrl());
      final token = await api.readAccessToken();
      if (token == null || auth.userId == null) {
        throw Exception('Not Authenticated');
      }

      // Build items payload
      final items = cart.items
          .map((i) => {
                'product_id': int.tryParse(i.productId) ?? 0,
                'name': i.name,
                'unit_price': i.price, // CartItem.price (unit price)
                'quantity': i.quantity,
              })
          .toList();

      final resp = await api.checkoutEnhanced(
        token: token,
        userId: auth.userId!,
        items: items,
        paymentMethod: _payment,
        shippingMethod: _shipping.startsWith('Self') ? 'self' : '2days',
        address: _addressCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        deliveryFee: _deliveryFee,
      );

      // Success: clear cart and show confirmation
      cart.clear();
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Order Placed'),
          content: Text(
            'Order placed successfully.\n'
            'Please refer to your order history\n'
            'Total: RM ${(resp['total'] as num).toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context); // back to cart
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout Failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _placing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final subtotal = cart.subtotal;
    final grandTotal = subtotal + _deliveryFee;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadProfile, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Payment
            DropdownButtonFormField<String>(
              value: _payment,
              items: const [
                DropdownMenuItem(
                  value: 'FPX Online Banking',
                  child: Text('FPX Online Banking'),
                ),
                DropdownMenuItem(
                  value: 'Credit/Debit Card',
                  child: Text('Credit/Debit Card'),
                ),
              ],
              onChanged: (v) => setState(() => _payment = v!),
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Shipping
            DropdownButtonFormField<String>(
              value: _shipping,
              items: const [
                DropdownMenuItem(
                  value: 'Self Collection (RM2)',
                  child: Text('Self Collection (RM2)'),
                ),
                DropdownMenuItem(
                  value: '2-Days Delivery (RM5)',
                  child: Text('2-Days Delivery (RM5)'),
                ),
              ],
              onChanged: (v) => setState(() => _shipping = v!),
              decoration: const InputDecoration(
                labelText: 'Shipping Method',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text('Delivery fee: RM ${_deliveryFee.toStringAsFixed(2)}'),

            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _row('Items', '${cart.totalItems}'),
                    const SizedBox(height: 4),
                    _row('Subtotal', 'RM ${subtotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 4),
                    _row('Delivery', 'RM ${_deliveryFee.toStringAsFixed(2)}'),
                    const Divider(height: 16),
                    _row('Total', 'RM ${grandTotal.toStringAsFixed(2)}',
                        bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _placing ? null : _placeOrder,
                child: _placing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Pay & Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String r, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 18 : 16,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Row(
      children: [Text(l, style: style), const Spacer(), Text(r, style: style)],
    );
  }
}
