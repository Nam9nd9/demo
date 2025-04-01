import 'package:mobile/model/cart_item.dart';

class Invoice {
  final int id;
  final String name;
  final List<Item> items;
  final double discount;
  final String discountType; // "%" hoặc "value"
  final double customerPaid;
  final double customerDeposit;
  final String depositMethod;
  final String customer_id;
  final String branch;
  final bool isDelivery;
  final String? orderSource;

  Invoice({
    required this.id,
    required this.name,
    required this.items,
    required this.discount,
    required this.discountType,
    required this.customerPaid,
    required this.customerDeposit,
    required this.depositMethod,
    required this.customer_id,
    required this.branch,
    required this.isDelivery,
    this.orderSource,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      name: json['name'],
      items: (json['items'] as List)
          .map((item) => Item.fromJson(item))
          .toList(),
      discount: json['discount'].toDouble(),
      discountType: json['discountType'],
      customerPaid: json['customerPaid'].toDouble(),
      customerDeposit: json['customerDeposit'].toDouble(),
      depositMethod: json['depositMethod'],
      customer_id: json['customer_id'],
      branch: json['branch'],
      isDelivery: json['isDelivery'],
      orderSource: json['orderSource'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
      'discount': discount,
      'discountType': discountType,
      'customerPaid': customerPaid,
      'customerDeposit': customerDeposit,
      'depositMethod': depositMethod,
      'customer_id': customer_id,
      'branch': branch,
      'isDelivery': isDelivery,
      'orderSource': orderSource,
    };
  }
}
