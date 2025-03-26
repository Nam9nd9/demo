import 'package:flutter/material.dart';
import 'package:mobile/screen/customer/customer_screen.dart';
import 'package:mobile/screen/product/product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ProductScreen(),
    const CustomerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.5), 
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey, 
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2),
              label: 'Sản phẩm',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.face),
              label: 'Khách hàng',
            ),
          ],
        ),
      ),
    );
  }
}
