import 'package:flutter/material.dart';
import '../model/cart_item.dart';


class CartProvider extends ChangeNotifier {
  final List<Item> _cartItems = [];
  double _cartDiscount = 0; 

  List<Item> get cartItems => _cartItems;

  int get cartCount => _cartItems.length;

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
      _cartItems.add(Item(
        productId: productId,
        quantity: quantity,
        price: price,
        discount: discount,
      ));
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
      print("🔹 Sản phẩm: ${item.productId}, Số lượng: ${item.quantity}, Giá: ${item.price}, Giảm giá: ${item.discount}");
    }
  }
}


  void removeItem(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

    int totalQuantity() {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }
  double totalPrice() {
    double total = _cartItems.fold(0, (sum, item) {
      return sum + (item.price * item.quantity);
    });
    return total * (1 - _cartDiscount / 100);
  }

  void updateDiscount(double discount) {
    _cartDiscount = discount.clamp(0, 100); // Giới hạn từ 0% đến 100%
    notifyListeners();
  }
}
