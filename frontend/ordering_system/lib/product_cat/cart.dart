import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_providers.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body:
          cart.items.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, i) {
                        final it = cart.items[i];
                        return ListTile(
                          title: Text(it.name),
                          subtitle: Text('\$${it.price.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed:
                                    () => cart.updateQuantity(
                                      it.productId,
                                      it.quantity - 1,
                                    ),
                              ),
                              Text('${it.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed:
                                    () => cart.updateQuantity(
                                      it.productId,
                                      it.quantity + 1,
                                    ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              '\$${cart.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          child: const Text('Proceed to Checkout'),
                          //                                           ?? /Checkout/Address ??
                          onPressed:
                              () => Navigator.pushNamed(context, '/checkout'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
