import 'package:flutter/material.dart';

import 'package:mobile/service/api_service.dart';
import 'package:mobile/widget/advancedDropdownButton.dart';
import 'package:mobile/widget/cart_icon.dart';
import 'package:mobile/widget/create_custumer.dart';
import 'package:mobile/widget/customer_search.dart';

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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Scaffold(
                                  body: Column(                                 
                                    children: [
                                      SizedBox(height: statusBarHeight),
                                      _buildHeader(context),
                                      const Expanded(child: CreateCustomerBody()),
                                    ],
                                  ),
                          )),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerSearchPage(customers: customers),
                        ),
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
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: customers.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 0.5,
                        color: const Color(0xFF555E5C).withOpacity(0.3),
                      ),
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
Widget _buildHeader(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    color: Colors.white,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              onPressed: () {
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF338BFF), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text("Tạo khách hàng", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8), 
        const Text(
          "Tạo Khách Hàng",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

}
