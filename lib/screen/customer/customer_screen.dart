import 'package:flutter/material.dart';
import 'package:mobile/model/customer.dart';
import 'package:mobile/screen/account/login_screen.dart';
import 'package:mobile/screen/customer/detail_screen.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _debtController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedGroupId;
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;
  List<Map<String, dynamic>> customers = [];
  String selectedGroup = "Tất cả";
  final Map<String, String> groupList = {
    "1": "Khách lẻ",
    "2": "Khách VIP",
    "3": "Khách buôn - CTV",
    "4": "Thành Viên",
  };
  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    final response = await ApiService.getCustomers(0, 50);
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
                        final formData = CustomerFormData();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => Scaffold(
                                  body: Column(
                                    children: [
                                      SizedBox(height: MediaQuery.of(context).padding.top),
                                      _buildHeader(
                                        context,
                                        formData,
                                        onCreated: () {
                                          fetchCustomers(); // ✅ reload lại danh sách
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Tạo khách hàng thành công"),
                                            ),
                                          );
                                        },
                                      ),
                                      Expanded(child: CreateCustomerBody(form: formData)),
                                    ],
                                  ),
                                ),
                          ),
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
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xB23C3C43),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  customers.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: customers.length,
                        separatorBuilder:
                            (context, index) => Divider(
                              height: 0.5,
                              color: const Color(0xFF555E5C).withOpacity(0.3),
                            ),
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          if (selectedGroup != "Tất cả" &&
                              customer['group_name'] != selectedGroup) {
                            return const SizedBox.shrink();
                          }
                          return ListTile(
                            title: Text(customer['full_name'] ?? "Không có tên"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("SĐT: ${customer['phone'] ?? 'Không có'}"),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: "Công nợ: ",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${customer['debt'] ?? '0'} ",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: "· Điểm tích lũy: ",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${customer['loyalty_points'] ?? '0'}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CustomerDetailScreen(
                                        customerId: customer['id'].toString(),
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    CustomerFormData formData, {
    required VoidCallback onCreated,
  }) {
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
                onPressed: () async {
                  if (formData.formKey.currentState!.validate() ?? false) {
                    final payload = {
                      "full_name": formData.nameController.text,
                      "date_of_birth": formData.selectedDate?.toIso8601String().split('T').first,
                      "debt": formData.debtController.text,
                      "phone": formData.phoneController.text,
                      "email": formData.emailController.text,
                      "address": formData.addressController.text,
                      "group_id": formData.selectedGroupId,
                      "province": formData.selectedProvince,
                      "district": formData.selectedDistrict,
                      "ward": formData.selectedWard,
                    };
                    // print(payload);
                    try {
                      await ApiService.createCustomer(payload);
                      print(payload);
                      onCreated();
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF338BFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: const Text("Tạo khách hàng", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text("Tạo Khách Hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
