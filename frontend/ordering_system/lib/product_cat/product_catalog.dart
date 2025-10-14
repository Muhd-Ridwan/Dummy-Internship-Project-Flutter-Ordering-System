import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'dart:math';
import 'package:dio/dio.dart';
import '../models/cart_item.dart';
import 'dart:math' as math;

// IMPORTING PROVIDERS
import '../providers/cart_providers.dart';
import 'package:provider/provider.dart';
import '../service/api_services.dart';
// import '../models/product.dart';

class SimpleProductCatalog extends StatefulWidget {
  const SimpleProductCatalog({super.key});

  @override
  State<SimpleProductCatalog> createState() => _SimpleProductCatalogState();
}

class _SimpleProductCatalogState extends State<SimpleProductCatalog> {
  final ApiServices api = ApiServices(baseUrl: ApiServices.defaultBaseUrl());
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await api.fetchProducts();
      setState(() {
        _products = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // PRODUCT CARD
  Widget _buildCard(Map<String, dynamic> p) {
    final name = (p['name'] ?? p['title'] ?? 'No name').toString();
    final price = p['price'] != null ? p['price'].toString() : '0';
    final category = (p['category'] ?? '').toString();
    final brand = (p['brand'] ?? '').toString();
    final image = (p['image'] ?? p['image_url'] ?? '').toString();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Builder(
                builder: (context) {
                  // ENSURING IMAGE HAVE IMAGE URL
                  //final image = (p['image'] ?? p['image_url'] ?? '').toString();
                  final base = ApiServices.defaultBaseUrl();
                  final imageUrl =
                      image.isEmpty
                          ? ''
                          : (image.startsWith('http') ? image : '$base$image');

                  return imageUrl.isEmpty
                      ? Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.memory, size: 48),
                        ),
                      )
                      : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder:
                            (c, e, st) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.broken_image),
                              ),
                            ),
                      );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$brand • $category',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Price: \$${price}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Category: $category',
                    style: GoogleFonts.montserrat(fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Brand: $brand',
                    style: GoogleFonts.montserrat(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Builder(
                    builder: (context) {
                      final pid = (p['id'] ?? p['pk'] ?? '').toString();
                      final priceVal =
                          double.tryParse(p['price']?.toString() ?? '0') ?? 0.0;
                      final cart = context.watch<CartProvider>();
                      final idx = cart.items.indexWhere(
                        (c) => c.productId == pid,
                      );
                      final qty = idx >= 0 ? cart.items[idx].quantity : 0;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // MINUS BUTTON
                          SizedBox(
                            height: 36,
                            width: 36,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed:
                                  qty > 0
                                      ? () {
                                        cart.updateQuantity(pid, qty - 1);
                                      }
                                      : null,
                              child: const Icon(Icons.remove, size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // QTY DISPLAY
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$qty',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // PLUS BUTTON
                          SizedBox(
                            height: 36,
                            width: 36,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                if (qty > 0) {
                                  cart.updateQuantity(pid, qty + 1);
                                } else {
                                  cart.addItem(
                                    productId: pid,
                                    name: name,
                                    price: priceVal,
                                    qty: 1,
                                  );
                                }
                              },
                              child: const Icon(Icons.add, size: 18),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Category: $category',
                    style: GoogleFonts.montserrat(fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Brand: $brand',
                    style: GoogleFonts.montserrat(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Text(
            'Product Catalog',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          actionsIconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $_error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    // MAIN IS HERE
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Product Catalog',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          // ADD LOGOUT BUTTON IN ACTION
          actions: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                final confirmLogout = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text(
                          'Logout from your account? Your selection and cart will not be saved.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('LOGOUT'),
                          ),
                        ],
                      ),
                );
                if (confirmLogout == true) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (r) => false,
                  );
                }
              },
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double maxAvailable = constraints.maxWidth;
            final double containerMaxWidth =
                maxAvailable > 1200 ? 1200.0 : maxAvailable;
            const double minCardWidth = 300.0;
            final int crossAxisCount = math.max(
              1,
              (containerMaxWidth / minCardWidth).floor(),
            );
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: containerMaxWidth),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, i) => _buildCard(_products[i]),
                ),
              ),
            );
          },
          //       _products.isEmpty
          //           ? Center(
          //             child: Text('No products', style: GoogleFonts.montserrat()),
          //           )
          //           : GridView.builder(
          //             padding: const EdgeInsets.all(12),
          //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //               crossAxisCount: 2,
          //               crossAxisSpacing: 12,
          //               mainAxisSpacing: 12,
          //               childAspectRatio: 0.7,
          //             ),
          //             itemCount: _products.length,
          //             itemBuilder: (context, i) => _buildCard(_products[i]),
          //           ),
          // ),
        ),
      ),
    );
  }
}
