import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_providers.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart (${cart.totalItems})',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
      ),
      body:
          cart.items.isEmpty
              ? Center(
                child: Text(
                  'Your cart is empty',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final it = cart.items[i];

                        final img = (it.meta['image'] ?? '') as String?;
                        final unit = it.price; // single unit price
                        final total = it.lineTotal; // unit * qty

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: _Thumb(imageUrl: img),
                          title: Text(
                            it.name,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RM ${total.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'RM ${unit.toStringAsFixed(2)} each',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Decrease',
                                icon: const Icon(Icons.remove),
                                onPressed:
                                    () => cart.updateQuantity(
                                      it.productId,
                                      it.quantity - 1,
                                    ),
                              ),
                              Text(
                                '${it.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Increase',
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
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            Text(
                              'RM ${cart.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Items: ${cart.totalItems}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                cart.items.isEmpty
                                    ? null
                                    : () => Navigator.pushNamed(
                                      context,
                                      '/checkout',
                                    ),
                            child: const Text('Proceed to Checkout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? imageUrl;
  const _Thumb({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 56,
        height: 56,
        child:
            url.isEmpty
                ? Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.photo, color: Colors.grey),
                )
                : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                ),
      ),
    );
  }
}

// class CartScreen extends StatelessWidget {
//   const CartScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final cart = context.watch<CartProvider>();
//     // final totalPrice = cart.subtotal;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Cart')),
//       body:
//           cart.items.isEmpty
//               ? Center(
//                 child: Text(
//                   'Your cart is empty',
//                   style: GoogleFonts.montserrat(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                   ),
//                 ),
//               )
//               : Column(
//                 children: [
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: cart.items.length,
//                       itemBuilder: (context, i) {
//                         final it = cart.items[i];
//                         return ListTile(
//                           title: Text(it.name),
//                           subtitle: Text('\RM ${it.price.toStringAsFixed(2)}'),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.remove),
//                                 onPressed:
//                                     () => cart.updateQuantity(
//                                       it.productId,
//                                       it.quantity - 1,
//                                     ),
//                               ),
//                               Text('${it.quantity}'),
//                               IconButton(
//                                 icon: const Icon(Icons.add),
//                                 onPressed:
//                                     () => cart.updateQuantity(
//                                       it.productId,
//                                       it.quantity + 1,
//                                     ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               'Subtotal',
//                               style: TextStyle(fontSize: 18),
//                             ),
//                             Text(
//                               'RM ${cart.subtotal.toStringAsFixed(2)}',
//                               style: const TextStyle(fontSize: 18),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         ElevatedButton(
//                           child: const Text('Proceed to Checkout'),
//                           //                                           ?? /Checkout/Address ??
//                           onPressed:
//                               () => Navigator.pushNamed(context, '/checkout'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//     );
//   }
// }
