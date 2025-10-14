import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '';
import '../models/cart_item.dart';

class CartItem {
  final String productId;
  final String name;
  final double price;
  int quantity;
  final Map<String, dynamic> meta;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.meta = const {},
  });

  double get lineTotal => price * quantity;
}

/// =======================
/// Controller (ChangeNotifier)
/// =======================

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (s, i) => s + i.quantity);

  double get subtotal => items.fold(0.0, (s, i) => s + i.lineTotal);

  void addItem({
    required String productId,
    required String name,
    required double price,
    int qty = 1,
    Map<String, dynamic> meta = const {},
  }) {
    final idx = _items.indexWhere((c) => c.productId == productId);
    if (idx >= 0) {
      _items[idx].quantity += qty;
    } else {
      _items.add(
        CartItem(
          productId: productId,
          name: name,
          price: price,
          quantity: qty,
          meta: meta,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((c) => c.productId == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final idx = _items.indexWhere((c) => c.productId == productId);
    if (idx >= 0) {
      if (quantity <= 0) {
        _items.removeAt(idx);
      } else {
        _items[idx].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Checkout Helper that posts each cart item to purchase endpoint.
  ///
  Future<List<Response>> checkout({
    required String apiBase,
    required Dio dio,
    required String shippingAddress,
    required String shippingMethod,
  }) async {
    final results = <Response>[];
    for (final it in List<CartItem>.from(_items)) {
      final url = '$apiBase/api/products/${it.productId}/purchase/';
      final data = {
        'quantity': it.quantity,
        'shipping_address': shippingAddress,
        'shipping_method': shippingMethod,
      };
      final resp = await dio.post(url, data: data);
      results.add(resp);
    }
    clear();
    return results;
  }
}
