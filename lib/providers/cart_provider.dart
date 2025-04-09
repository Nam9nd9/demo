import 'package:flutter/material.dart';
import '../model/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<Item> _cartItems = [];
  double _cartDiscount = 0;
  String _discountType = "%"; // Loại chiết khấu: % hoặc VND

  List<Item> get cartItems => _cartItems;
  int get cartCount => _cartItems.length;
  double get discount => _cartDiscount;
  String get discountType => _discountType;

  void addToCart(String productId, int quantity, double price, double discount) {
    final index = _cartItems.indexWhere((item) => item.productId == productId);

    if (index != -1) {
      int newQuantity = _cartItems[index].quantity + quantity;
      _cartItems[index] = Item(
        productId: productId,
        quantity: newQuantity,
        price: price,
        discount: discount,
      );
    } else {
      _cartItems.add(
        Item(productId: productId, quantity: quantity, price: price, discount: discount),
      );
    }

    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.productId == productId);

    if (index != -1) {
      if (newQuantity > 0) {
        _cartItems[index] = Item(
          productId: productId,
          quantity: newQuantity,
          price: _cartItems[index].price,
          discount: _cartItems[index].discount,
        );
      } else {
        removeItem(productId);
      }
      notifyListeners();
      print("📌 Giỏ hàng hiện tại:");
      for (var item in _cartItems) {
        print(
          "🔹 Sản phẩm: ${item.productId}, Số lượng: ${item.quantity}, Giá: ${item.price}, Giảm giá: ${item.discount}",
        );
      }
    }
  }

  void removeItem(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _cartDiscount = 0;
    _discountType = "%";
    notifyListeners();
  }

  int totalQuantity() {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double totalPrice() {
    double total = _cartItems.fold(0, (sum, item) {
      return sum + (item.price * item.quantity);
    });

    if (_discountType == "%") {
      return total * (1 - _cartDiscount / 100);
    } else {
      return (total - _cartDiscount).clamp(0, double.infinity);
    }
  }

  void updateDiscount(double discount, String discountType) {
    _discountType = discountType;
    if (discountType == "%") {
      _cartDiscount = discount.clamp(0, 100);
    } else {
      _cartDiscount = discount.clamp(0, totalPrice());
    }
    notifyListeners();
  }
}
