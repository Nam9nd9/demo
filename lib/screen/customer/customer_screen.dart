import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/delegates/customer_search_delegate.dart';
import 'package:mobile/screen/account/login_screen.dart';
import 'package:mobile/service/api_service.dart';
import 'package:mobile/widget/advancedDropdownButton.dart';
import 'package:mobile/widget/cart_icon.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({Key? key}) : super(key: key);

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  List<Map<String, dynamic>> customers = [];
  String selectedGroup = "Tất cả";
  final List<String> groupList = ["Tất cả", "Khách Lẻ", "VIP", "Thành Viên"];

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    final response = await ApiService.getCustomers(0, 20);
    if (response != null && response['customers'] != null) {
      setState(() {
        customers = List<Map<String, dynamic>>.from(response['customers']);
      });
    }
  }

  void _handleLogout() async {
    await ApiService.signout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: statusBarHeight),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Khách hàng",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        _handleLogout();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: CustomerSearchDelegate(customers),
                        );
                      },
                    ),
                    CartIcon(),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AdvancedDropdownButton(
              items: groupList,
              hint: "Chọn nhóm khách hàng",
              onChanged: (value) {
                setState(() {
                  selectedGroup = value;
                });
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Danh sách khách hàng",
                style: TextStyle(fontSize: 15, color: Color(0xB23C3C43), fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: customers.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        if (selectedGroup != "Tất cả" && customer['group_name'] != selectedGroup) {
                          return const SizedBox.shrink();
                        }
                        return ListTile(
                          title: Text(customer['full_name'] ?? "Không có tên"),
                          subtitle: Text("SĐT: ${customer['phone'] ?? 'Không có'}"),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () {},
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
