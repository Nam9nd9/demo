import 'package:mobile/model/cart_item.dart';

class Invoice {
  final String id;
  final String name;
  final List<Item> items;
  final double discount;
  final String discountType;
  final double customerPaid;
  final double customerDeposit;
  final String depositMethod;
  final String? customer;
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
    this.customer,
    required this.branch,
    required this.isDelivery,
    this.orderSource,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      items: (json['items'] as List?)?.map((item) => Item.fromJson(item)).toList() ?? [],
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discount_type'] ?? '%',
      customerPaid: (json['customerPaid'] as num?)?.toDouble() ?? 0.0,
      customerDeposit: (json['customerDeposit'] as num?)?.toDouble() ?? 0.0,
      depositMethod: json['depositMethod'] ?? 'cash',
      customer: json['customer'],
      branch: json['branch'] ?? '',
      isDelivery: json['is_delivery'] ?? false,
      orderSource: json['order_source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "items": items.map((item) => item.toJson()).toList(),
      "discount": discount,
      "discount_type": discountType,
      "customerPaid": customerPaid,
      "customerDeposit": customerDeposit,
      "depositMethod": depositMethod,
      "customer": customer,
      "branch": branch,
      "is_delivery": isDelivery,
      "order_source": orderSource,
    };
  }
}
