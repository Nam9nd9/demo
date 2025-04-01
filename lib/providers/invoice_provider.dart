import 'package:flutter/material.dart';
import 'package:mobile/model/cart_item.dart';

class InvoiceProvider with ChangeNotifier {
  Map<String, dynamic>? _customer;
  String _selectedWarehouse = "Thợ Nhuộm";
  double _discount = 0;
  String _userId = "NV1";
  String _discountType = "%";
  double _extraCost = 0;
  bool _isDelivery = false;
  String _orderSource = "";
  String _depositMethod = "cash";
  double _deposit = 0;
  String _expectedDelivery = "";
  List<Item> _items = [];

  Map<String, dynamic>? get selectedCustomer => _customer;
  String get selectedWarehouse => _selectedWarehouse;
  double get discount => _discount;
  String get userId => _userId;
  String get discountType => _discountType;
  double get extraCost => _extraCost;
  bool get isDelivery => _isDelivery;
  String get orderSource => _orderSource;
  String get depositMethod => _depositMethod;
  double get deposit => _deposit;
  String get expectedDelivery => _expectedDelivery;
  List<Item> get items => _items;

  // Setters
  void updateInvoice(Map<String, dynamic> data) {
    _customer = data["customer"];
    _userId = data["user_id"] ?? "NV1"; // default "NV1" if null
    _selectedWarehouse = data["branch"] ?? "Thợ Nhuộm"; // default "Thợ Nhuộm" if null
    _discount = (data["discount"] ?? 0).toDouble();
    _discountType = data["discount_type"] ?? "%"; // default "%" if null
    _deposit = (data["deposit"] ?? 0).toDouble();
    _depositMethod = data["deposit_method"] ?? "cash"; // default "cash" if null
    _isDelivery = data["is_delivery"] ?? false; // default false if null
    _expectedDelivery = data["expected_delivery"] ?? "";
    _orderSource = data["order_source"] ?? "";
    _extraCost = (data["extraCost"] ?? 0).toDouble();
    _items = (data["items"] as List)
        .map((item) => Item.fromJson(item))
        .toList();

    notifyListeners();
  }

  void clearInvoice() {
    _customer = null;
    _selectedWarehouse = "Thợ Nhuộm";
    _discount = 0;
    _discountType = "%";
    _deposit = 0;
    _depositMethod = "cash";
    _isDelivery = false;
    _expectedDelivery = "";
    _orderSource = "";
    _extraCost = 0;
    _items.clear();

    notifyListeners();
  }
   void updateDepositMethod(String method) {
    _depositMethod = method;
    notifyListeners();
  }

  void updateDeposit(double deposit) {
    _deposit = deposit;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      "customer": _customer, 
      "user_id": _userId,
      "branch": _selectedWarehouse,
      "discount": _discount,
      "discountType": _discountType,
      "deposit": _deposit,
      "depositMethod": _depositMethod,
      "isDelivery": _isDelivery,
      "expectedDelivery": _expectedDelivery,
      "orderSource": _orderSource,
      "extraCost": _extraCost,
      "items": _items.map((item) => item.toJson()).toList(),
    };
  }
}
