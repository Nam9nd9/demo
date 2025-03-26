import 'package:flutter/material.dart';
import '../model/cart_item.dart';


class CartProvider extends ChangeNotifier {
  final List<Item> _cartItems = [];

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
      removeItem(productId); // Xóa nếu số lượng <= 0
    }
    notifyListeners();
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
}
