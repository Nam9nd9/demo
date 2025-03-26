import 'package:flutter/material.dart';
import 'package:mobile/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;

    return Scaffold(
      appBar: AppBar(title: Text("Giỏ hàng")),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? Center(child: Text("Giỏ hàng trống"))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("ID: ${item.productId}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey), 
                                  borderRadius: BorderRadius.circular(8), 
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 8), 
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove, color: Colors.red),
                                      onPressed: () {
                                        if (item.quantity > 1) {
                                          cartProvider.updateQuantity(item.productId, item.quantity - 1);
                                        }
                                      },
                                    ),
                                    Container(
                                      width: 40, 
                                      alignment: Alignment.center,
                                      child: Text(
                                        item.quantity.toString(),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add, color: Colors.green),
                                      onPressed: () {
                                        cartProvider.updateQuantity(item.productId, item.quantity + 1);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
