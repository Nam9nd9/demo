import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:mobile/model/customer.dart';
import 'package:mobile/service/api_service.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:table_calendar/table_calendar.dart';

class CreateCustomerBody extends StatefulWidget {
  final CustomerFormData form;

  const CreateCustomerBody({Key? key, required this.form}) : super(key: key);

  @override
  _CreateCustomerBodyState createState() => _CreateCustomerBodyState();
}

String _customerGroup = 'Đại lý';
final List<Map<String, String>> _customerGroups = [
  {"id": "1", "name": "Khách Buôn - CTV"},
  {"id": "2", "name": "Vip"},
  {"id": "4", "name": "Khách buôn"},
  {"id": "5", "name": "Khách lẻ"},
];

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
  List<Map<String, String>> _customerGroups = [];
  String? _selectedGroupId;

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;

  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();

  bool _showCalendar = false;
  DateTime? _selectedDate = DateTime.now();
  bool _showYearSelector = false;

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
    _fetchCustomerGroups();
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
        key: widget.form.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 10, color: Color(0xFFF2F2F7)),
              _buildSectionTitle("Thông tin cá nhân"),
              _buildTextField("Tên khách hàng", widget.form.nameController),
              _buildInlineBirthDatePicker("Ngày sinh", widget.form.dobController),

              Container(height: 10, color: Color(0xFFF2F2F7)),
              _buildSectionTitle("Thông tin quản lý"),
              _buildGroupDropdownField(),
              _buildTextField("Công nợ", widget.form.debtController, isNumber: true),

              Container(height: 10, color: Color(0xFFF2F2F7)),
              _buildSectionTitle("Thông tin liên hệ"),
              _buildTextField("Số điện thoại", widget.form.phoneController, isNumber: true),
              _buildTextField("Email", widget.form.emailController),

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

              _buildTextField("Địa chỉ", widget.form.addressController),
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

  Widget _buildTextField(
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
                    hintText:
                        label == "Email"
                            ? "Không bắt buộc"
                            : (isDate ? "dd/mm/yy" : (label == "Địa chỉ" ? "Yêu cầu" : "Bắt buộc")),
                    hintStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIcon:
                        isDate ? const Icon(Icons.calendar_today, color: Colors.grey) : null,
                  ),
                  validator: (value) {
                    if (label == "Email" || label == "Địa chỉ") {
                      return null; // Không cần kiểm tra nếu là email hoặc địa chỉ
                    }
                    return value!.isEmpty
                        ? "Vui lòng nhập $label"
                        : null; // Kiểm tra các trường còn lại
                  },
                ),
              ),
            ],
          ),
        ),
        Divider(height: 0.5, color: const Color(0xFF555E5C).withOpacity(0.3)),
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
                value: widget.form.selectedGroupId,
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

  Widget _buildInlineBirthDatePicker(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showCalendar = !_showCalendar;
                    });
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: controller,
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: "dd/mm/yyyy",
                        hintStyle: TextStyle(color: Colors.grey),
                        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_showCalendar)
          Theme(
            data: ThemeData(
              useMaterial3: true,
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF338BFF),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: CalendarDatePicker(
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              currentDate: DateTime.now(),
              onDateChanged: (newDate) {
                setState(() {
                  widget.form.selectedDate = newDate;
                  controller.text =
                      "${newDate.day.toString().padLeft(2, '0')}/"
                      "${newDate.month.toString().padLeft(2, '0')}/"
                      "${newDate.year}";
                  _showCalendar = false;
                });
              },
            ),
          ),
        const Divider(height: 0.5, color: Color(0xFF555E5C), thickness: 0.3),
      ],
    );
  }
}
