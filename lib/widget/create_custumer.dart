import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:mobile/service/api_service.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CreateCustomerBody extends StatefulWidget {
  const CreateCustomerBody({Key? key}) : super(key: key);

  @override
  _CreateCustomerBodyState createState() => _CreateCustomerBodyState();
}
String _customerGroup = 'Đại lý';
final List<String> _customerGroups = ['Đại lý', 'Khách VIP', 'Khách buôn-CTV', 'Khách lẻ','Khách Trắng'];

class _CreateCustomerBodyState extends State<CreateCustomerBody> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _debtController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _wards = [];

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;

  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    final data = await ApiService.getProvinces();
    if (data != null) {
      setState(() {
        _provinces = data;
      });
    }
    print(data);
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 10, color: Color(0xFFF2F2F7)),
              _buildSectionTitle("Thông tin cá nhân"),
              _buildTextField("Tên khách hàng", _nameController),
              _buildTextField("Ngày sinh", _dobController, isDate: true),

              Container(height: 10, color: Color(0xFFF2F2F7)),
              _buildSectionTitle("Thông tin quản lý"),
              _buildDropdownField("Nhóm khách hàng", _customerGroups, _customerGroup, (newValue) {
                setState(() {
                  _customerGroup = newValue!;
                });
              }),
              _buildTextField("Công nợ", _debtController, isNumber: true),

              Container(height: 10, color: Color(0xFFF2F2F7)),
              _buildSectionTitle("Thông tin liên hệ"),
              _buildTextField("Số điện thoại", _phoneController, isNumber: true),
              _buildTextField("Email", _emailController),

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
                  _fetchDistricts(_provinces.firstWhere((p) => p['ProvinceName'] == value)['ProvinceID'].toString());
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
                  _fetchWards(_districts.firstWhere((d) => d['DistrictName'] == value)['DistrictID'].toString());
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

              _buildTextField("Địa chỉ", _addressController),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, bool isDate = false}) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SizedBox(width: 160, child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400))),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                  readOnly: isDate,
                  onTap: isDate
                      ? () {
                          picker.DatePicker.showDatePicker(
                            context,
                            showTitleActions: true,
                            minTime: DateTime(1900, 1, 1),
                            maxTime: DateTime.now(),
                            onConfirm: (date) {
                              controller.text = "${date.day}/${date.month}/${date.year}";
                            },
                            currentTime: DateTime.now(),
                            locale: picker.LocaleType.vi,
                          );
                        }
                      : null,
                  decoration: InputDecoration(
                    hintText: label == "Email"
                      ? "Không bắt buộc"
                      : (isDate
                          ? "dd/mm/yy"
                          : (label == "Địa chỉ" ? "Yêu cầu" : "Bắt buộc")),
                    hintStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIcon: isDate ? const Icon(Icons.calendar_today, color: Colors.grey) : null,
                  ),
                  validator: (value) => value!.isEmpty ? "Vui lòng nhập $label" : null,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 0.5, color: const Color(0xFF555E5C).withOpacity(0.3)),
      ],
    );
  }
Widget _buildDropdownField(String label, List<String> items, String selectedValue, Function(String?) onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            SizedBox(
              width: 165,
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
            ),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                ),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
                dropdownColor: Colors.white, 
              ),
            )
          ],
        ),
      ),
    ],
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
              width: 160,
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
                    hintText: "Yêu cầu",
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  containerBuilder: (context, popupWidget) {
                    return Container(
                      color: Colors.white, 
                      child: popupWidget,
                    );
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
            )
          ],
        ),
      ),
    ],
  );
}
}
