import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/service/api_service.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;
  const CustomerDetailScreen({Key? key, required this.customerId}) : super(key: key);

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

final List<Map<String, String>> _customerGroups = [
  {"id": "1", "name": "Khách Buôn - CTV"},
  {"id": "2", "name": "Vip"},
  {"id": "4", "name": "Khách buôn"},
  {"id": "5", "name": "Khách lẻ"},
];

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

  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _wards = [];
  List<Map<String, String>> _customerGroups = [];
  String? _selectedGroupId;
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;
  DateTime? _selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    _fetchProvinces();
    _fetchCustomerGroups();
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

  Future<void> _fetchProvinces() async {
    final data = await ApiService.getProvinces();
    if (data != null) {
      setState(() {
        _provinces = data;
      });
    }
  }

  Future<void> _fetchDistricts(String provinceId) async {
    final data = await ApiService.getDistricts(provinceId);
    if (data != null) {
      setState(() {
        _districts = data;
        _selectedDistrict = null;
        _wards = [];
        _selectedWard = null;
      });
    }
  }

  Future<void> _fetchWards(String districtId) async {
    final data = await ApiService.getWards(districtId);
    if (data != null) {
      setState(() {
        _wards = data;
        _selectedWard = null;
      });
    }
  }

  _fetchCustomerGroups() async {
    final response = await ApiService.getCustomerGroups();
    if (response != null && response["groups"] != null) {
      setState(() {
        _customerGroups =
            (response["groups"] as List)
                .map((g) => {"id": g["id"].toString(), "name": g["name"].toString()})
                .toList();
      });
    }
  }

  Future<void> _fetchCustomerDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final customerData = await ApiService.getCustomerById(widget.customerId);
    final dobStr = customerData?["date_of_birth"];
    if (customerData != null) {
      setState(() {
        _nameController.text = customerData["full_name"] ?? "";
        _dobController.text = customerData["date_of_birth"] ?? "";
        if (dobStr != null && dobStr is String && dobStr.isNotEmpty) {
          _selectedDate = DateTime.tryParse(dobStr);
          if (_selectedDate != null) {
            _dobController.text =
                "${_selectedDate!.day.toString().padLeft(2, '0')}/"
                "${_selectedDate!.month.toString().padLeft(2, '0')}/"
                "${_selectedDate!.year}";
          }
        }
        _phoneController.text = customerData["phone"] ?? "";
        _emailController.text = customerData["email"] ?? "";
        _addressController.text = customerData["address"] ?? "";
        _selectedGroupId = customerData["group"]?["id"]?.toString();

        _provinceController.text = customerData["province"] ?? "";
        _districtController.text = customerData["district_name"] ?? "";
        _wardController.text = customerData["ward_name"] ?? "";
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCustomerDetails() async {
    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> customerData = {
      "full_name": _nameController.text.trim(),
      "date_of_birth": _selectedDate?.toIso8601String().split('T').first,
      "phone": _phoneController.text,
      "email": _emailController.text,
      "address": _addressController.text,
      "province": _provinceController.text,
      "district_name": _districtController.text,
      "ward_name": _wardController.text,
      "group_id": _selectedGroupId,
    };

    bool success = await ApiService.updateCustomer(widget.customerId, customerData);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Lưu thông tin thành công")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Lưu thất bại! Vui lòng thử lại.")));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _debtController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: statusBarHeight),
          _buildHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _hasError
                      ? const Center(child: Text("❌ Lỗi khi tải dữ liệu"))
                      : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Thông tin cá nhân"),
                            _buildEditableTextField("Tên khách hàng", _nameController),
                            _buildEditableTextField("Ngày sinh", _dobController, isDate: true),

                            _buildSectionTitle("Thông tin quản lý"),
                            _buildGroupDropdownField(),
                            _buildEditableTextField("Công nợ", _debtController),

                            _buildSectionTitle("Thông tin liên hệ"),
                            _buildEditableTextField("Số điện thoại", _phoneController),
                            _buildEditableTextField("Email", _emailController),
                            _buildSearchableField(
                              "Tỉnh/Thành phố",
                              _provinceController,
                              _provinces.map((p) => p['ProvinceName'].toString()).toList(),
                              (value) {
                                setState(() {
                                  _selectedProvince = value;
                                  _selectedDistrict = null;
                                  _selectedWard = null;
                                  _districtController.clear();
                                  _wardController.clear();
                                });
                                _fetchDistricts(
                                  _provinces
                                      .firstWhere((p) => p['ProvinceName'] == value)['ProvinceID']
                                      .toString(),
                                );
                              },
                            ),
                            _buildSearchableField(
                              "Quận/Huyện",
                              _districtController,
                              _districts.map((d) => d['DistrictName'].toString()).toList(),
                              (value) {
                                setState(() {
                                  _selectedDistrict = value;
                                  _selectedWard = null;
                                  _wardController.clear();
                                });
                                _fetchWards(
                                  _districts
                                      .firstWhere((d) => d['DistrictName'] == value)['DistrictID']
                                      .toString(),
                                );
                              },
                            ),
                            _buildSearchableField(
                              "Phường/Xã",
                              _wardController,
                              _wards.map((w) => w['WardName'].toString()).toList(),
                              (value) {
                                setState(() {
                                  _selectedWard = value;
                                });
                              },
                            ),
                            _buildEditableTextField("Địa chỉ", _addressController),
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
            onPressed: _saveCustomerDetails,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF338BFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEditableTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isDate = false,
  }) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 160,
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                  readOnly: isDate,
                  onTap:
                      isDate
                          ? () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData(
                                    useMaterial3: true, // << QUAN TRỌNG
                                    colorScheme: ColorScheme.light(
                                      primary: Color(0xFF338BFF), // màu giống ảnh bạn gửi
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedDate != null) {
                              setState(() {
                                _selectedDate = pickedDate;
                                controller.text =
                                    "${pickedDate.day.toString().padLeft(2, '0')}/"
                                    "${pickedDate.month.toString().padLeft(2, '0')}/"
                                    "${pickedDate.year}";
                              });
                            }
                          }
                          : null,
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIcon:
                        isDate ? const Icon(Icons.calendar_today, color: Colors.grey) : null,
                  ),
                  validator: (value) => value!.isEmpty ? "Vui lòng nhập $label" : null,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
      ],
    );
  }

  Widget _buildGroupDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(
              width: 160,
              child: Text("Nhóm khách hàng", style: TextStyle(fontSize: 15)),
            ),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedGroupId,
                decoration: const InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                ),
                items:
                    _customerGroups.map((group) {
                      return DropdownMenuItem<String>(
                        value: group["id"],
                        child: Text(group["name"] ?? ""),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGroupId = newValue;
                  });
                },
                dropdownColor: Colors.white,
                isExpanded: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchableField(
    String label,
    TextEditingController controller,
    List<String> items,
    Function(String) onSelected,
  ) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 160,
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
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
                      hintText: "Yêu cầu",
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    containerBuilder: (context, popupWidget) {
                      return Container(color: Colors.white, child: popupWidget);
                    },
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm...",
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
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
