import 'package:flutter/material.dart';
import 'package:mobile/screen/cart/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/cart_provider.dart'; 

class CartIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return badges.Badge(
          badgeContent: Text(
            cartProvider.cartCount.toString(),
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          position: badges.BadgePosition.topEnd(top: 0, end: 3),
          child: IconButton(
            icon: const Icon(Icons.shopping_cart,color: Colors.blue, ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        );
      },
    );
  }
}
