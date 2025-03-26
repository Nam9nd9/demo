import 'package:flutter/material.dart';

class CreateCustomerBody extends StatefulWidget {
  const CreateCustomerBody({Key? key}) : super(key: key);

  @override
  _CreateCustomerBodyState createState() => _CreateCustomerBodyState();
}

class _CreateCustomerBodyState extends State<CreateCustomerBody> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _debtController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _customerGroup = 'Đại lý';
  final List<String> _customerGroups = ['Đại lý', 'Khách VIP', 'Khách buôn', 'Khách lẻ'];

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
              Container(
                height: 10,
                color: Color(0xFFF2F2F7),
              ),
              _buildSectionTitle("Thông tin cá nhân"),
              _buildTextField("Tên khách hàng", _nameController),
              _buildTextField("Ngày sinh", _dobController, isDate: true),
              const SizedBox(height: 16),
              Container(
                height: 10,
                color: Color(0xFFF2F2F7),
              ),
              _buildSectionTitle("Thông tin quản lý"),
              _buildDropdownField("Nhóm khách hàng", _customerGroups, _customerGroup, (newValue) {
                setState(() {
                  _customerGroup = newValue!;
                });
              }),
              _buildTextField("Công nợ", _debtController, isNumber: true),
              const SizedBox(height: 16),
              Container(
                height: 10,
                color: Color(0xFFF2F2F7)
              ),
              _buildSectionTitle("Thông tin liên hệ"),
              _buildTextField("Số điện thoại", _phoneController, isNumber: true),
              _buildTextField("Email", _emailController),
              _buildTextField("Tỉnh/Thành phố", TextEditingController()),
              _buildTextField("Quận/Huyện", TextEditingController()),
              _buildTextField("Phường/Xã", TextEditingController()),
              _buildTextField("Địa chỉ", _addressController),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context); 
                  }
                },
                child: const Text("Tạo Khách Hàng", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
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
              SizedBox(
                width: 120,
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
                  onTap: isDate
                      ? () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            controller.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          }
                        }
                      : null,
                  decoration: InputDecoration(
                    hintText: isDate ? "DD/MM/YY" : "Bắt buộc",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none, // Loại bỏ viền
                    suffixIcon: isDate ? const Icon(Icons.calendar_today, color: Colors.grey) : null,
                  ),
                  validator: (value) => value!.isEmpty ? "Vui lòng nhập $label" : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Divider(
          height: 0.5,
          color: const Color(0xFF555E5C).withOpacity(0.3),
        ), // Đường ngăn cách
      ],
    );
  }


  Widget _buildDropdownField(String label, List<String> items, String value, Function(String?) onChanged) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: value,
                  items: items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item,style: TextStyle(color:  Colors.grey),),
                    );
                  }).toList(),
                  onChanged: onChanged,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10), 
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Divider(
          height: 0.5,
          color: const Color(0xFF555E5C).withOpacity(0.3),
        ), 
      ],
    );
  }

}
