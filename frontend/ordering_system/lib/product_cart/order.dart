import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ordering_system/service/api_services.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _orders = [];

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
      final api = ApiServices(baseUrl: ApiServices.defaultBaseUrl());
      final token = await api.readAccessToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      final data = await api.fetchOrders(token);
      // (Optional) sort newest first by created_at
      data.sort((a, b) {
        final da = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(1970);
        final db = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(1970);
        return db.compareTo(da);
      });
      setState(() => _orders = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String s, BuildContext context) {
    final status = s.toUpperCase();
    if (status == 'PENDING') return Colors.amber.shade700;
    if (status == 'SHIPPED') return Colors.blue.shade600;
    if (status == 'DELIVERED' || status == 'COMPLETED') return Colors.green.shade700;
    return Theme.of(context).colorScheme.secondary; // fallback
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    // Simple dd MMM yyyy, HH:mm
    return '${dt.day.toString().padLeft(2, '0')} '
        '${_mon(dt.month)} ${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _mon(int m) => const [
        'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
      ][(m - 1).clamp(0, 11)];

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
        ),
      ),
      body: _orders.isEmpty
          ? Center(
              child: Text(
                'You have no orders yet.',
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _orders.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final o = _orders[i];
                  // Fields expected from your OrderSerializer:
                  // id, status, quantity, total_price, created_at, product: { name, image, price, ... }
                  final id = o['id']?.toString();
                  final status = (o['status'] ?? '').toString();
                  final qty = (o['quantity'] ?? 0) as int;
                  final total = (o['total_price'] ?? 0).toString();
                  final createdAt = (o['created_at'] ?? '').toString();

                  final product = (o['product'] ?? {}) as Map<String, dynamic>;
                  final pname = (product['name'] ?? 'Product').toString();
                  final pimg = (product['image'] ?? '').toString();

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    leading: _OrderThumb(imageUrl: pimg),
                    title: Text(
                      pname,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order #$id  •  x$qty',
                            style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 2),
                        Text('Placed: ${_formatDate(createdAt)}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor(status, context).withOpacity(.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: _statusColor(status, context)),
                              ),
                              child: Text(
                                status.isEmpty ? 'UNKNOWN' : status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _statusColor(status, context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        Text(
                          'RM $total',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    onTap: () {
                      // (Optional) push to an order-details page later
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _OrderThumb extends StatelessWidget {
  final String imageUrl;
  const _OrderThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 56,
        height: 56,
        child: url.isEmpty
            ? Container(
                color: Colors.grey[200],
                child: const Icon(Icons.inventory_2, color: Colors.grey),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
      ),
    );
  }
}
