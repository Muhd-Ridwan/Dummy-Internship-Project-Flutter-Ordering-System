import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ordering_system/providers/auth_provider.dart';
//import 'package:http/http.dart';
//import 'dart:math';
//import 'package:dio/dio.dart';
//import '../models/cart_item.dart';
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
  // TO SHOW THE QUANTITY OFF ADDING ITEMS
  final Map<String, int> _pendingQty = {};

  int _getPendingQty(String pid) => _pendingQty[pid] ?? 0;
  void _setPendingQty(String pid, int value) {
    setState(() {
      _pendingQty[pid] = value.clamp(0, 999);
    });
  }

  // SEARCH RELATED
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<Map<String, dynamic>> _allProducts = [];

  final ApiServices api = ApiServices(baseUrl: ApiServices.defaultBaseUrl());

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _products = [];

  // HELPER FOR SEARCH FUNCTION START
  void _applyFilter() {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _products = List<Map<String, dynamic>>.from(_allProducts);
      });
      return;
    }
    // SPLITTING WORDS
    final tokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    bool matches(Map<String, dynamic> p) {
      // HANDLING BOTH FLAT & FIELDS SHAPE SAFELY
      String field(dynamic map, String key) {
        if (map == null) {
          return '';
        }
        if (map is Map && map.containsKey(key)) {
          return (map[key] ?? '').toString();
        }
        if (map is Map && map.containsKey('fields')) {
          final f = map['fields'];
          if (f is Map && f.containsKey(key)) {
            return (f[key] ?? '').toString();
          }
        }
        return '';
      }

      final name = field(p, 'name').toLowerCase();
      final title = field(p, 'title').toLowerCase();
      final brand = field(p, 'brand').toLowerCase();
      final category = field(p, 'category').toLowerCase();
      final desc = field(p, 'description').toLowerCase();

      final hay = '$name $title $brand $category $desc';
      return tokens.every((t) => hay.contains(t));
    }

    setState(() {
      _products = _allProducts.where(matches).toList();
    });
  }
  // HELPER FOR SEARCHING END

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        _allProducts = data;
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
    final id = (p['id'] ?? p['pk'] ?? '').toString();
    final name = (p['name'] ?? p['title'] ?? 'No name').toString();
    final price = p['price'] != null ? p['price'].toString() : '0';
    final category = (p['category'] ?? '').toString();
    final brand = (p['brand'] ?? '').toString();
    final image = (p['image'] ?? p['image_url'] ?? '').toString();
    final stock = p['stock'] != null ? p['stock'].toString() : '0';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:
            () => _showProductDetailsDialog(
              context,
              id,
            ), // () => _showProductDetailsDialog(context, id),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$brand • $category',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Stock: $stock',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Price: RM $price',
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Category: $category',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Brand: $brand',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Builder(
                    builder: (context) {
                      final pid = (p['id'] ?? p['pk'] ?? '').toString();
                      final priceVal =
                          double.tryParse(p['price']?.toString() ?? '0') ?? 0.0;

                      // USE LOCAL SELECTOR QTY
                      final qty = _getPendingQty(pid);
                      // final cart = context.watch<CartProvider>();
                      // final idx = cart.items.indexWhere(
                      //   (c) => c.productId == pid,
                      // );

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
                                        _setPendingQty(pid, qty - 1);
                                      }
                                      : null,
                              child: const Icon(Icons.remove, size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // QUANTITY DISPLAY
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
                                _setPendingQty(pid, qty + 1);
                                // if (qty > 0) {
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //     const SnackBar(
                                //       content: Text(
                                //         'There is nothing to add to cart for this item',
                                //       ),
                                //     ),
                                //   );
                                // } else {
                                //   cart.addItem(
                                //     productId: pid,
                                //     name: name,
                                //     price: priceVal,
                                //     qty: 1,
                                //   );
                                // }
                              },
                              child: const Icon(Icons.add, size: 18),
                            ),
                          ),
                          const Spacer(), // PUSHING EVERYTHING AFTER THIS CODE TO THE MOST RIGHT
                          // ADD TO CART BUTTON
                          IconButton.filled(
                            onPressed:
                                int.tryParse(stock) != 0
                                    ? () async {
                                      final auth =
                                          context.read<AppAuthProvider>();
                                      final cartProv =
                                          context.read<CartProvider>();
                                      // final qtyToAdd = qty > 0 ? qty : 1;

                                      if (qty <= 0) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'There are no items to add to cart for this item',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      // IF USER LOGGED IN, TRY TO ADD TO SERVER CART FIRST
                                      if (auth.isLoggedIn &&
                                          auth.userId != null) {
                                        final productIdInt =
                                            int.tryParse(pid) ?? 0;
                                        try {
                                          await api.addToCart(
                                            userId: auth.userId!,
                                            productId: productIdInt,
                                            name: name,
                                            price: priceVal * qty,
                                            quantity: qty,
                                            token: auth.token,
                                          );
                                          cartProv.addItem(
                                            productId: pid,
                                            name: name,
                                            price: priceVal * qty,
                                            qty: qty,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('Added to cart'),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to add to cart: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        // IF NOT LOGGED IN. IT WILL KEEP THE CART LOCALLY
                                        cartProv.addItem(
                                          productId: pid,
                                          name: name,
                                          price: priceVal,
                                          qty: qty,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Added to local cart(login to sync)',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                    : null,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(44, 44),
                            ),
                            icon: const Icon(Icons.add_shopping_cart_rounded),
                            tooltip: 'Add to Cart',
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 5),
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
            Builder(
              builder: (ctx) {
                final auth = ctx.read<AppAuthProvider>();
                final count = ctx.watch<CartProvider>().items.length;
                return IconButton(
                  constraints: const BoxConstraints(),
                  tooltip: 'Cart',
                  onPressed: () {
                    if (!auth.isLoggedIn || auth.userId == null) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Please login first')),
                      );
                      return;
                    }
                    Navigator.pushNamed(ctx, '/cart');
                  },
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart),
                      if (count > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              count.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            IconButton(
              // padding: EdgeInsets.only(right: 20),
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
                if (confirmLogout != true) return;

                // SECURE SIGN OUT TO CLEAR TOKEN
                final api = ApiServices(baseUrl: ApiServices.defaultBaseUrl());
                final auth = context.read<AppAuthProvider>();
                final cart = context.read<CartProvider>();
                await api.deleteAccessToken();
                auth.logout();
                cart.clear();

                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (r) => false,
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          // BOTTOM OF APPBAR
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (q) {
                  _searchQuery = q;
                  _applyFilter();
                  setState(() {});
                  // No need to call setState here as _applyFilter already does that
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search Products...',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  suffixIcon:
                      _searchQuery.isEmpty
                          ? null
                          : IconButton(
                            tooltip: 'Clear',
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery = '';
                              _applyFilter();
                              setState(() {});
                              // DISMISSING KEYBOARD (EXTRA FEATURES ONLY)
                              FocusScope.of(context).unfocus();
                            },
                          ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
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
                    childAspectRatio: 0.65, // Adjusted for better card height
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, i) {
                    //final product = _products[i];
                    return _buildCard(_products[i]);
                  }, //_buildCard(_products[i]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// HELPER METHOD TO SHOW THE DETAILS
Future<void> _showProductDetailsDialog(
  BuildContext context,
  dynamic productId,
) async {
  final api = ApiServices(baseUrl: ApiServices.defaultBaseUrl());
  await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<Map<String, dynamic>>(
            future: api.fetchProductDetails(productId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 36,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load product details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString()),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('CLOSE'),
                    ),
                  ],
                );
              }
              final data = snapshot.data!;
              final title = data['name'] ?? data['title'] ?? 'Product';
              final description =
                  data['description'] ?? 'No description available';
              final price = data['price']?.toString() ?? '';
              // IMAGE
              final base = ApiServices.defaultBaseUrl();
              final rawImage =
                  (data['image'] ?? data['image_url'] ?? '').toString();
              final imageUrl =
                  rawImage.isEmpty
                      ? ''
                      : (rawImage.startsWith('http')
                          ? rawImage
                          : '$base$rawImage');

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ADDING IMAGE
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child:
                          imageUrl.isEmpty
                              ? Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.memory, size: 48),
                                ),
                              )
                              : Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                errorBuilder:
                                    (c, e, st) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(Icons.broken_image),
                                      ),
                                    ),
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (price.isNotEmpty)
                      Text(
                        'Price: \RM ${price}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    const SizedBox(height: 12),
                    Text(description),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('CLOSE'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
