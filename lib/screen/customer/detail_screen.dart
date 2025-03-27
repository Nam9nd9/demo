import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/service/api_service.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;
  const CustomerDetailScreen({Key? key, required this.customerId}) : super(key: key);

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  late final TextEditingController _debtController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _provinceController;
  late final TextEditingController _districtController;
  late final TextEditingController _wardController;
  String _customerGroup = "N/A";
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dobController = TextEditingController();
    _debtController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _provinceController = TextEditingController();
    _districtController = TextEditingController();
    _wardController = TextEditingController();
    _fetchCustomerDetails();
  }

Future<void> _fetchCustomerDetails() async {
  setState(() {
    _isLoading = true;
    _hasError = false;
  });

  final customerData = await ApiService.getCustomerById(widget.customerId);
  if (customerData != null) {
    setState(() {
      _nameController.text = customerData["full_name"] ?? "Chưa có dữ liệu";
      _dobController.text = customerData["date_of_birth"] ?? "Chưa có dữ liệu";
      _debtController.text = customerData["debt"]?.toString() ?? "0"; 
      _phoneController.text = customerData["phone"] ?? "Chưa có dữ liệu";
      _emailController.text = customerData["email"] ?? "Chưa có dữ liệu";
      _addressController.text = customerData["address"] ?? "Chưa có dữ liệu";
      _customerGroup = customerData["group"]?["name"] ?? "N/A";
      _provinceController.text = customerData["province"] ?? "Chưa có dữ liệu";
      _districtController.text = customerData["district_name"] ?? "Chưa có dữ liệu";
      _wardController.text = customerData["ward_name"] ?? "Chưa có dữ liệu";

      _isLoading = false;
    });
  } else {
    setState(() {
      _hasError = true;
      _isLoading = false;
    });
  }
}


  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _debtController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final double statusBarHeight = MediaQuery.of(context).padding.top;
  return Scaffold(
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: statusBarHeight), // Khoảng trống cho StatusBar
        _buildHeader(context), // Thêm Header tùy chỉnh

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                    ? const Center(child: Text("❌ Lỗi khi tải dữ liệu"))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 10, color: Color(0xFFF2F2F7)),
                            _buildSectionTitle("Thông tin cá nhân"),
                            _buildReadOnlyTextField("Tên khách hàng", _nameController),
                            _buildReadOnlyTextField("Ngày sinh", _dobController),

                            _buildSectionTitle("Thông tin quản lý"),
                            _buildReadOnlyDropdown("Nhóm khách hàng", _customerGroup),
                            _buildReadOnlyTextField("Công nợ", _debtController),

                            _buildSectionTitle("Thông tin liên hệ"),
                            _buildReadOnlyTextField("Số điện thoại", _phoneController),
                            _buildReadOnlyTextField("Email", _emailController),
                            _buildSearchableField("Tỉnh/Thành phố", _provinceController, ["Hà Nội", "Hồ Chí Minh", "Lào Cai"], (value) {}),
                            _buildSearchableField("Quận/Huyện", _districtController, ["Huyện Si Ma Cai", "Huyện Bát Xát"], (value) {}),
                            _buildSearchableField("Xã/Phường", _wardController, ["Thị Trấn Si Ma Cai", "Xã Nậm Chảy"], (value) {}),
                            _buildReadOnlyTextField("Địa chỉ", _addressController),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildReadOnlyTextField(String label, TextEditingController controller) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: true,
                  decoration: const InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 0.5, color: const Color(0xFF555E5C).withOpacity(0.3)),
      ],
    );
  }

  Widget _buildReadOnlyDropdown(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(value, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 0.5, color: const Color(0xFF555E5C).withOpacity(0.3)),
      ],
    );
  }
  Widget _buildHeader(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          onPressed: (){},
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF338BFF), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text("Lưu thông tin", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    ),
  );
}
Widget _buildSearchableField(String label, TextEditingController controller, List<String> items, Function(String) onSelected) {
  return Column(
    children: [
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
            ),
            Expanded(
              child: DropdownSearch<String>(
                items: items,
                onChanged: (value) {
                  if (value != null) {
                    controller.text = value;
                    onSelected(value);
                  }
                },
                selectedItem: controller.text.isNotEmpty ? controller.text : null,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: "Nhập để tìm kiếm...",
                    enabledBorder:  InputBorder.none,
                    focusedBorder:  InputBorder.none,
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
}