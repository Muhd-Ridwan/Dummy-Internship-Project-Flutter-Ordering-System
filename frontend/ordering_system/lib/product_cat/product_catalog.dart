import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'dart:math';
import 'package:dio/dio.dart';
import '../models/cart_item.dart';

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
              child:
                  image.isEmpty
                      ? Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.memory, size: 48),
                        ),
                      )
                      : Image.network(image, fit: BoxFit.cover),
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
        appBar: AppBar(title: const Text('Product Catalog')),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Product Catalog')),
      body:
          _products.isEmpty
              ? Center(
                child: Text('No products', style: GoogleFonts.montserrat()),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemCount: _products.length,
                itemBuilder: (context, i) => _buildCard(_products[i]),
              ),
    );
  }
}



































// WILL USE THIS LATER PERHAPS


// /// =============================
// /// Domain models (Django will fill)
// /// =============================
// class Product {
//   final String id;
//   final String name;
//   final String category; // GPU/RAM/SSD/HDD/...
//   final String brand;
//   final double price;
//   final Map<String, dynamic>
//   specs; // e.g. {'capacityGB': 1024, 'speedMHz': 3600, ...}

//   Product({
//     required this.id,
//     required this.name,
//     required this.category,
//     required this.brand,
//     required this.price,
//     required this.specs,
//   });

//   // TODO(DRF): mapping api using json to domain model
//   factory Product.fromJson(Map<String, dynamic> json) {
//     //
//     final specs = <String, dynamic>{};
//     if (json['specs'] is Map) {
//       specs.addAll(Map<String, dynamic>.from(json['specs'] as Map));
//     }
//     if (json.containsKey('capacity') && json['capacity'] != null)
//       specs['capacityGB'] = json['capacity'];
//     if (json.containsKey('capacity_gb') && json['capacity_gb'] != null)
//       specs['capacityGB'] = json['capacity_gb'];
//     if (json.containsKey('speed') && json['speed'] != null)
//       specs['speedMHz'] = json['speed'];
//     if (json.containsKey('speed_mhz') && json['speed_mhz'] != null)
//       specs['speedMHz'] = json['speed_mhz'];

//     return Product(
//       id: json['id'].toString(),
//       name: (json['name'] ?? json['title'] ?? '').toString(),
//       category: (json['category'] ?? json['category_name'] ?? '').toString(),
//       brand: (json['brand'] ?? '').toString(),
//       price: double.tryParse((json['price'] ?? '0').toString()) ?? 0.0,
//       specs: specs,
//     );
//   }
// }

// class PagedResult<T> {
//   final List<T> items;
//   final int total; // total rows from server
//   final int page; // current page index (1-based)
//   final int pageSize; // server page size
//   PagedResult({
//     required this.items,
//     required this.total,
//     required this.page,
//     required this.pageSize,
//   });
// }

// /// =======================================
// /// Repository contract (plug Django here)
// /// =======================================
// enum SortBy { popularity, priceLowHigh, priceHighLow, newest }

// abstract class CatalogRepository {
//   /// TODO(DRF): Implement GET /products with these query params
//   Future<PagedResult<Product>> fetchProducts({
//     required int page,
//     required int pageSize,
//     String? search,
//     String? category,
//     String? brand,
//     double? priceMin,
//     double? priceMax,
//     int? capacityMinGB,
//     int? capacityMaxGB,
//     int? speedMinMHz,
//     int? speedMaxMHz,
//     String? interfaceType, // NVMe/SATA/PCIe 4.0, etc.
//     SortBy sortBy = SortBy.popularity,
//   });

//   /// Optional: preload dropdown/filter sources from DRF (e.g. /filters/*)
//   Future<List<String>> fetchCategories(); // GPU/RAM/SSD/HDD...
//   Future<List<String>> fetchBrands(); // NVIDIA/AMD/Kingston/Samsung...
//   Future<List<String>> fetchInterfaces(); // NVMe/SATA/PCIe 4.0...
// }

// /// Temporary empty repository so UI renders (returns nothing).
// /// Replace with your real DRF implementation and pass it into ProductCatalog().
// class ApiCatalogRepository implements CatalogRepository {
//   final ApiServices api;

//   ApiCatalogRepository({required this.api});

//   @override
//   Future<PagedResult<Product>> fetchProducts({
//     required int page,
//     required int pageSize,
//     String? search,
//     String? category,
//     String? brand,
//     double? priceMin,
//     double? priceMax,
//     int? capacityMinGB,
//     int? capacityMaxGB,
//     int? speedMinMHz,
//     int? speedMaxMHz,
//     String? interfaceType,
//     SortBy sortBy = SortBy.popularity,
//   }) async {
//     final raw = await api.fetchProducts();
//     final items = raw.map((m) => Product.fromJson(m)).toList();
//     return PagedResult(
//       items: items,
//       total: items.length,
//       page: page,
//       pageSize: pageSize,
//     );
//   }

//   @override
//   Future<List<String>> fetchBrands() async {
//     // TODO(DRF): GET /api/filters/brands
//     return const [];
//   }

//   @override
//   Future<List<String>> fetchCategories() async {
//     // TODO(DRF): GET /api/filters/categories
//     return const [];
//   }

//   @override
//   Future<List<String>> fetchInterfaces() async {
//     // TODO(DRF): GET /api/filters/interfaces
//     return const [];
//   }
// }

// // FALLBACK IF EMPTY REPOSITORY

// class EmptyCatalogRepository implements CatalogRepository {
//   // final ApiServices api;

//   // EmptyCatalogRepository({required this.api});

//   @override
//   Future<PagedResult<Product>> fetchProducts({
//     required int page,
//     required int pageSize,
//     String? search,
//     String? category,
//     String? brand,
//     double? priceMin,
//     double? priceMax,
//     int? capacityMinGB,
//     int? capacityMaxGB,
//     int? speedMinMHz,
//     int? speedMaxMHz,
//     String? interfaceType,
//     SortBy sortBy = SortBy.popularity,
//   }) async {
//     return PagedResult(
//       items: const [],
//       total: 0,
//       page: page,
//       pageSize: pageSize,
//     );
//     // final raw = await api.fetchProducts();
//     // final items = raw.map((m) => Product.fromJson(m)).toList();
//     // return PagedResult(
//     //   items: items,
//     //   total: items.length,
//     //   page: page,
//     //   pageSize: pageSize,
//     // );
//   }

//   @override
//   Future<List<String>> fetchBrands() async {
//     // TODO(DRF): GET /api/filters/brands
//     return const [];
//   }

//   @override
//   Future<List<String>> fetchCategories() async {
//     // TODO(DRF): GET /api/filters/categories
//     return const [];
//   }

//   @override
//   Future<List<String>> fetchInterfaces() async {
//     // TODO(DRF): GET /api/filters/interfaces
//     return const [];
//   }
// }

// // FALL BACK END

// class CatalogController extends ChangeNotifier {
//   CatalogController(this.repo);

//   final CatalogRepository repo;

//   // Query state
//   String? search;
//   String? category;
//   String? brand;
//   double? priceMin;
//   double? priceMax;
//   int? capacityMinGB;
//   int? capacityMaxGB;
//   int? speedMinMHz;
//   int? speedMaxMHz;
//   String? interfaceType;
//   SortBy sortBy = SortBy.popularity;

//   // Paging (infinite scroll)
//   final int pageSize = 20;
//   int _page = 1;
//   bool loading = false;
//   bool reachedEnd = false;

//   // Data
//   final List<Product> products = [];
//   int total = 0;

//   // Filter sources
//   List<String> categories = [];
//   List<String> brands = [];
//   List<String> interfaces = [];

//   Future<void> bootstrap() async {
//     loading = true;
//     notifyListeners();

//     // TODO(DRF): optionally load filter sources
//     categories = await repo.fetchCategories();
//     brands = await repo.fetchBrands();
//     interfaces = await repo.fetchInterfaces();

//     // first page
//     await refresh();

//     loading = false;
//     notifyListeners();
//   }

//   Future<void> refresh() async {
//     products.clear();
//     _page = 1;
//     reachedEnd = false;
//     await _loadPage();
//   }

//   Future<void> loadMore() async {
//     if (loading || reachedEnd) return;
//     _page += 1;
//     await _loadPage();
//   }

//   Future<void> _loadPage() async {
//     loading = true;
//     notifyListeners();

//     final res = await repo.fetchProducts(
//       page: _page,
//       pageSize: pageSize,
//       search: search,
//       category: category,
//       brand: brand,
//       priceMin: priceMin,
//       priceMax: priceMax,
//       capacityMinGB: capacityMinGB,
//       capacityMaxGB: capacityMaxGB,
//       speedMinMHz: speedMinMHz,
//       speedMaxMHz: speedMaxMHz,
//       interfaceType: interfaceType,
//       sortBy: sortBy,
//     );

//     products.addAll(res.items);
//     total = res.total;
//     if (res.items.isEmpty || products.length >= total) {
//       reachedEnd = true;
//     }

//     loading = false;
//     notifyListeners();
//   }

//   void clearFilters() {
//     search = null;
//     category = null;
//     brand = null;
//     priceMin = null;
//     priceMax = null;
//     capacityMinGB = null;
//     capacityMaxGB = null;
//     speedMinMHz = null;
//     speedMaxMHz = null;
//     interfaceType = null;
//     sortBy = SortBy.popularity;
//     refresh();
//   }
// }

// // FLUTTER BODY START HERE

// class ProductCatalog extends StatefulWidget {
//   const ProductCatalog({
//     super.key,
//     this.repository, // FOR APICATALOGREPOSITORY LATER
//   });

//   final CatalogRepository? repository; // FOR APICATALOGREPOSITORY LATER

//   @override
//   State<ProductCatalog> createState() => _ProductCatalogState();
// }

// class _ProductCatalogState extends State<ProductCatalog> {
//   late final CatalogController ctrl;
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//   final _searchCtrl = TextEditingController();
//   final _scrollCtrl = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     ctrl = CatalogController(widget.repository ?? EmptyCatalogRepository());
//     ctrl.bootstrap();

//     _scrollCtrl.addListener(() {
//       if (_scrollCtrl.position.pixels >=
//           _scrollCtrl.position.maxScrollExtent - 300) {
//         ctrl.loadMore();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _scrollCtrl.dispose();
//     _searchCtrl.dispose();
//     ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isWide = MediaQuery.of(context).size.width >= 1100;

//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         // leading: IconButton(
//         //   icon: const Icon(Icons.login_rounded, color: Colors.black),
//         //   tooltip: 'Login',
//         //   onPressed: () {
//         //     Navigator.pushReplacementNamed(context, '/login');
//         //   },
//         // ),
//         title: Text(
//           'Product Catalog',
//           style: GoogleFonts.montserrat(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//             color: Colors.black,
//           ),
//         ),
//         actions: [
//           AnimatedBuilder(
//             animation: ctrl,
//             builder: (_, __) {
//               return PopupMenuButton<SortBy>(
//                 tooltip: 'Sort',
//                 initialValue: ctrl.sortBy,
//                 onSelected: (v) {
//                   ctrl.sortBy = v;
//                   ctrl.refresh();
//                 },
//                 itemBuilder:
//                     (c) => const [
//                       PopupMenuItem(
//                         value: SortBy.popularity,
//                         child: Text('Popularity'),
//                       ),
//                       PopupMenuItem(
//                         value: SortBy.priceLowHigh,
//                         child: Text('Price: Low to High'),
//                       ),
//                       PopupMenuItem(
//                         value: SortBy.priceHighLow,
//                         child: Text('Price: High to Low'),
//                       ),
//                       PopupMenuItem(
//                         value: SortBy.newest,
//                         child: Text('Newest'),
//                       ),
//                     ],
//                 icon: const Icon(Icons.sort),
//               );
//             },
//           ),
//           if (!isWide)
//             IconButton(
//               tooltip: 'Filters',
//               icon: const Icon(Icons.tune),
//               onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
//             ),
//           const SizedBox(width: 10),
//         ],
//       ),
//       endDrawer: isWide ? null : Drawer(child: _FiltersPanel(ctrl: ctrl)),
//       body: Row(
//         children: [
//           // LEFT SIDEBAR
//           if (isWide)
//             ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 300),
//               child: _Sidebar(child: _FiltersPanel(ctrl: ctrl)),
//             ),
//           Expanded(
//             child: AnimatedBuilder(
//               animation: ctrl,
//               builder: (context, _) {
//                 return CustomScrollView(
//                   controller: _scrollCtrl,
//                   slivers: [
//                     SliverToBoxAdapter(
//                       child: Padding(
//                         padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//                         child: TextField(
//                           controller: _searchCtrl,
//                           onSubmitted: (v) {
//                             ctrl.search = v.isEmpty ? null : v;
//                             ctrl.refresh();
//                           },
//                           decoration: InputDecoration(
//                             hintText: 'Search GPU / RAM / SSD / HDD..',
//                             prefixIcon: const Icon(Icons.search),
//                             isDense: true,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SliverToBoxAdapter(child: _AppliedChips(ctrl: ctrl)),

//                     // GRID OF THE PRODUCTS
//                     if (ctrl.products.isEmpty && !ctrl.loading)
//                       const SliverFillRemaining(
//                         hasScrollBody: false,
//                         child: Center(child: Text('No products found')),
//                       )
//                     else
//                       SliverPadding(
//                         padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//                         sliver: SliverGrid(
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2,
//                                 childAspectRatio: 0.78,
//                                 mainAxisSpacing: 16,
//                                 crossAxisSpacing: 16,
//                               ),
//                           delegate: SliverChildBuilderDelegate(
//                             (context, i) => _ProductCard(p: ctrl.products[i]),
//                             childCount: ctrl.products.length,
//                           ),
//                         ),
//                       ),

//                     // LOADING / END INDICATOR
//                     SliverToBoxAdapter(
//                       child: Padding(
//                         padding: const EdgeInsets.only(bottom: 24),
//                         child: Center(
//                           child:
//                               ctrl.loading
//                                   ? const Padding(
//                                     padding: EdgeInsets.all(12),
//                                     child: CircularProgressIndicator(),
//                                   )
//                                   : ctrl.reachedEnd
//                                   ? const Text('End of results')
//                                   : const SizedBox.shrink(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // UI COMPONENTS

// class _Sidebar extends StatelessWidget {
//   final Widget child;
//   const _Sidebar({required this.child});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border(
//           right: BorderSide(color: Theme.of(context).dividerColor),
//         ),
//       ),
//       child: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: child,
//         ),
//       ),
//     );
//   }
// }

// class _FiltersPanel extends StatefulWidget {
//   final CatalogController ctrl;
//   const _FiltersPanel({required this.ctrl});
//   @override
//   State<_FiltersPanel> createState() => _FiltersPanelState();
// }

// class _FiltersPanelState extends State<_FiltersPanel> {
//   final _priceMinCtrl = TextEditingController();
//   final _priceMaxCtrl = TextEditingController();
//   final _capMinCtrl = TextEditingController();
//   final _capMaxCtrl = TextEditingController();
//   final _speedMinCtrl = TextEditingController();
//   final _speedMaxCtrl = TextEditingController();

//   String? _category;
//   String? _brand;
//   String? _iface;

//   @override
//   void initState() {
//     super.initState();
//     final f = widget.ctrl;
//     _category = f.category;
//     _brand = f.brand;
//     _iface = f.interfaceType;
//     _priceMinCtrl.text = f.priceMin?.toString() ?? '';
//     _priceMaxCtrl.text = f.priceMax?.toString() ?? '';
//     _capMinCtrl.text = f.capacityMinGB?.toString() ?? '';
//     _capMaxCtrl.text = f.capacityMaxGB?.toString() ?? '';
//     _speedMinCtrl.text = f.speedMinMHz?.toString() ?? '';
//     _speedMaxCtrl.text = f.speedMaxMHz?.toString() ?? '';
//   }

//   @override
//   void dispose() {
//     _priceMinCtrl.dispose();
//     _priceMaxCtrl.dispose();
//     _capMinCtrl.dispose();
//     _capMaxCtrl.dispose();
//     _speedMinCtrl.dispose();
//     _speedMaxCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = widget.ctrl;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Text(
//               'Filters',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
//             ),
//             const Spacer(),
//             TextButton.icon(
//               onPressed: ctrl.clearFilters,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Reset'),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),

//         _section(
//           'Category',
//           DropdownButtonFormField<String>(
//             value: _category,
//             hint: const Text('GPU / RAM / SSD / HDD'),
//             items:
//                 (ctrl.categories.isEmpty ? <String>[] : ctrl.categories)
//                     .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                     .toList(),
//             onChanged: (v) => setState(() => _category = v),
//           ),
//         ),
//         _section(
//           'Brand',
//           DropdownButtonFormField<String>(
//             value: _brand,
//             hint: const Text('Brand'),
//             items:
//                 (ctrl.brands.isEmpty ? <String>[] : ctrl.brands)
//                     .map((b) => DropdownMenuItem(value: b, child: Text(b)))
//                     .toList(),
//             onChanged: (v) => setState(() => _brand = v),
//           ),
//         ),
//         _section(
//           'Interface',
//           DropdownButtonFormField<String>(
//             value: _iface,
//             hint: const Text('NVMe / SATA / PCIe 4.0'),
//             items:
//                 (ctrl.interfaces.isEmpty ? <String>[] : ctrl.interfaces)
//                     .map((i) => DropdownMenuItem(value: i, child: Text(i)))
//                     .toList(),
//             onChanged: (v) => setState(() => _iface = v),
//           ),
//         ),

//         _section(
//           'Price (USD)',
//           Row(
//             children: [
//               Expanded(child: _num(_priceMinCtrl, 'Min')),
//               const SizedBox(width: 8),
//               Expanded(child: _num(_priceMaxCtrl, 'Max')),
//             ],
//           ),
//         ),
//         _section(
//           'Capacity (GB)',
//           Row(
//             children: [
//               Expanded(child: _num(_capMinCtrl, 'Min')),
//               const SizedBox(width: 8),
//               Expanded(child: _num(_capMaxCtrl, 'Max')),
//             ],
//           ),
//         ),
//         _section(
//           'Speed (MHz)',
//           Row(
//             children: [
//               Expanded(child: _num(_speedMinCtrl, 'Min')),
//               const SizedBox(width: 8),
//               Expanded(child: _num(_speedMaxCtrl, 'Max')),
//             ],
//           ),
//         ),
//         const SizedBox(height: 12),
//         FilledButton.icon(
//           onPressed: () {
//             ctrl.category = _category;
//             ctrl.brand = _brand;
//             ctrl.interfaceType = _iface;

//             double? d(String s) => s.trim().isEmpty ? null : double.tryParse(s);
//             int? i(String s) => s.trim().isEmpty ? null : int.tryParse(s);

//             ctrl.priceMin = d(_priceMinCtrl.text);
//             ctrl.priceMax = d(_priceMaxCtrl.text);
//             ctrl.capacityMinGB = i(_capMinCtrl.text);
//             ctrl.capacityMaxGB = i(_capMaxCtrl.text);
//             ctrl.speedMinMHz = i(_speedMinCtrl.text);
//             ctrl.speedMaxMHz = i(_speedMaxCtrl.text);

//             ctrl.refresh();
//           },
//           icon: const Icon(Icons.check),
//           label: const Text('Apply filters'),
//         ),
//       ],
//     );
//   }

//   Widget _num(TextEditingController c, String hint) => TextFormField(
//     controller: c,
//     keyboardType: TextInputType.number,
//     decoration: InputDecoration(
//       isDense: true,
//       hintText: hint,
//       border: const OutlineInputBorder(),
//     ),
//   );

//   Widget _section(String title, Widget child) => Padding(
//     padding: const EdgeInsets.only(bottom: 18),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
//         const SizedBox(height: 10),
//         child,
//       ],
//     ),
//   );
// }

// class _AppliedChips extends StatelessWidget {
//   final CatalogController ctrl;
//   const _AppliedChips({required this.ctrl});

//   @override
//   Widget build(BuildContext context) {
//     final chips = <Widget>[];

//     void add(String key, String? value, VoidCallback clear) {
//       if (value != null && value.isNotEmpty) {
//         chips.add(
//           InputChip(
//             label: Text('$key: $value'),
//             onDeleted: () {
//               clear();
//               ctrl.refresh();
//             },
//           ),
//         );
//       }
//     }

//     add('Category', ctrl.category, () => ctrl.category = null);
//     add('Brand', ctrl.brand, () => ctrl.brand = null);
//     add('Interface', ctrl.interfaceType, () => ctrl.interfaceType = null);

//     if (ctrl.priceMin != null || ctrl.priceMax != null) {
//       final min = ctrl.priceMin?.toStringAsFixed(0) ?? '0';
//       final max = ctrl.priceMax?.toStringAsFixed(0) ?? '∞';
//       chips.add(
//         InputChip(
//           label: Text('Price: \$$min–\$$max'),
//           onDeleted: () {
//             ctrl.priceMin = null;
//             ctrl.priceMax = null;
//             ctrl.refresh();
//           },
//         ),
//       );
//     }
//     if (ctrl.capacityMinGB != null || ctrl.capacityMaxGB != null) {
//       final min = ctrl.capacityMinGB?.toString() ?? '0';
//       final max = ctrl.capacityMaxGB?.toString() ?? '∞';
//       chips.add(
//         InputChip(
//           label: Text('Capacity: ${min}–${max}GB'),
//           onDeleted: () {
//             ctrl.capacityMinGB = null;
//             ctrl.capacityMaxGB = null;
//             ctrl.refresh();
//           },
//         ),
//       );
//     }
//     if (ctrl.speedMinMHz != null || ctrl.speedMaxMHz != null) {
//       final min = ctrl.speedMinMHz?.toString() ?? '0';
//       final max = ctrl.speedMaxMHz?.toString() ?? '∞';
//       chips.add(
//         InputChip(
//           label: Text('Speed: ${min}–${max}MHz'),
//           onDeleted: () {
//             ctrl.speedMinMHz = null;
//             ctrl.speedMaxMHz = null;
//             ctrl.refresh();
//           },
//         ),
//       );
//     }

//     if (chips.isEmpty) return const SizedBox(height: 8);
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//       child: Wrap(spacing: 8, runSpacing: 8, children: chips),
//     );
//   }
// }

// class _ProductCard extends StatelessWidget {
//   final Product p;
//   const _ProductCard({required this.p});

//   @override
//   Widget build(BuildContext context) {
//     final text = Theme.of(context).textTheme;

//     // Example subtitle logic (tailor to your API)
//     String subtitle = p.category;
//     if (p.category.toUpperCase() == 'RAM' && p.specs['speedMHz'] != null) {
//       subtitle = 'RAM • ${p.specs['speedMHz']} MHz';
//     } else if ((p.category.toUpperCase() == 'SSD' ||
//             p.category.toUpperCase() == 'HDD') &&
//         p.specs['capacityGB'] != null) {
//       subtitle = '${p.category} • ${p.specs['capacityGB']} GB';
//     } else if (p.category.toUpperCase() == 'GPU' &&
//         p.specs['interface'] != null) {
//       subtitle = 'GPU • ${p.specs['interface']}';
//     }

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: () {
//           // TODO(Navigation): push to product details page
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // TODO(Image): replace with image url from your API
//             AspectRatio(
//               aspectRatio: 4 / 3,
//               child: Container(
//                 color: Theme.of(context).colorScheme.surfaceVariant,
//                 child: const Center(child: Icon(Icons.memory, size: 48)),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 12, 12, 2),
//               child: Text(
//                 p.name,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
//               child: Text(
//                 '$subtitle • ${p.brand}',
//                 style: text.bodySmall?.copyWith(color: Colors.grey[600]),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
//               child: Text(
//                 '\$${p.price.toStringAsFixed(2)}',
//                 style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//               ),
//             ),
//             const Spacer(),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
//               child: Row(
//                 children: [
//                   OutlinedButton.icon(
//                     onPressed: () {
//                       // add to cart
//                       context.read<CartProvider>().addItem(
//                         productId: p.id,
//                         name: p.name,
//                         price: p.price,
//                         qty: 1,
//                         meta: p.specs ?? {},
//                       );
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('${p.name} added to cart')),
//                       );
//                     },
//                     icon: const Icon(Icons.add_shopping_cart),
//                     label: const Text('Add'),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     onPressed: () {
//                       // TODO(Wishlist)
//                     },
//                     icon: const Icon(Icons.favorite_border),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
