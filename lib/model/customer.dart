import 'package:flutter/material.dart';

class CustomerFormData {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final debtController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  final provinceController = TextEditingController();
  final districtController = TextEditingController();
  final wardController = TextEditingController();

  String? selectedGroupId;
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;

  DateTime? selectedDate;

  Map<String, dynamic> toJson() {
    return {
      "full_name": nameController.text,
      "date_of_birth": selectedDate?.toIso8601String().split('T').first, // ✅ định dạng yyyy-MM-dd
      "debt": debtController.text,
      "phone": phoneController.text,
      "email": emailController.text,
      "address": addressController.text,
      "group_id": selectedGroupId,
      "province": selectedProvince,
      "district": selectedDistrict,
      "ward": selectedWard,
    };
  }

  void dispose() {
    nameController.dispose();
    dobController.dispose();
    debtController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    provinceController.dispose();
    districtController.dispose();
    wardController.dispose();
  }
}
