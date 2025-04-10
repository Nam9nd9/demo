import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/providers/cart_provider.dart';
import 'package:mobile/screen/home_screen.dart';
import 'package:mobile/screen/product/product_screen.dart';

import 'package:mobile/service/api_service.dart';
import 'package:provider/provider.dart';

class InvoiceInfoScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceInfoScreen({Key? key, required this.invoiceId}) : super(key: key);

  @override
  _InvoiceInfoScreenState createState() => _InvoiceInfoScreenState();
}

class _InvoiceInfoScreenState extends State<InvoiceInfoScreen> {
  Map<String, dynamic>? invoiceData;
  final Map<String, String> depositMethods = {
    "cash": "Tiền mặt",
    "bank": "Chuyển khoản",
    "pos": "POS",
  };
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchInvoiceDetail();
  }

  Future<void> fetchInvoiceDetail() async {
    try {
      final response = await ApiService.fetchInvoiceDetail(widget.invoiceId);
      setState(() {
        invoiceData = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Lỗi khi tải thông tin hóa đơn";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (errorMessage != null) {
      return Scaffold(body: Center(child: Text(errorMessage!)));
    }
    final customer = invoiceData?['customer'] ?? {};
    final totalValue = invoiceData?['total_value'] ?? 0.0;
    final deposit = invoiceData?['deposit'] ?? 0.0;
    final extracost = invoiceData?['extraCost'] ?? 0.0;
    final currentFinalTotal = totalValue;
    final amountDue = currentFinalTotal - deposit - extracost;

    final createdAt =
        invoiceData?['created_at'] != null
            ? DateFormat('dd/MM/yy').format(DateTime.parse(invoiceData!['created_at']))
            : "Không có";
    String depositMethod = invoiceData!['deposit_method'] ?? 'Không có';
    String depositMethodLabel = depositMethods[depositMethod] ?? depositMethod;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: statusBarHeight),
          _buildHeader(context, amountDue),
          Container(height: 16, color: Color(0xFFF2F2F7)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text("Khách hàng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFD9D9D9), width: 1),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      customer['full_name'] ?? "Không có tên",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("SĐT: ${customer['phone'] ?? 'Không có'}"),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "Công nợ: ",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                              ),
                              TextSpan(
                                text: "${customer['debt'] ?? '0'} ",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: "· Điểm tích lũy: ",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                              ),
                              TextSpan(
                                text: "${customer['loyalty_points'] ?? '0'}",
                                style: TextStyle(
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
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Tóm tắt thanh toán",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFD9D9D9), width: 1),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ID Đơn hàng: ${invoiceData!['id']}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${NumberFormat("#,###", "vi_VN").format(deposit)} . ${depositMethods[invoiceData!['deposit_method']] ?? 'Không có'} . $createdAt ",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          buildStatusBadge(invoiceData!['status']),
                          SizedBox(width: 8), // Khoảng cách giữa 2 badge
                          buildPaymentStatusBadge(invoiceData!['payment_status']),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double amountDue) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed:
                    () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      ),
                      cartProvider.clearCart(),
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF338BFF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Hoàn thành", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
          Divider(),
          SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
              children: [
                TextSpan(text: amountDue < 0 ? "Tiền thừa trả khách: " : "Còn phải trả: "),
                TextSpan(
                  text: "${NumberFormat("#,###", "vi_VN").format(amountDue.abs())}",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildStatusBadge(String status) {
    Map<String, dynamic> statusStyles = {
      "cancel": {
        "text": "Đã huỷ",
        "color": Color(0xFF80000E),
        "bgColor": Color(0xFFFCE1DE),
        "icon": Icons.block,
      },
      "delivering": {
        "text": "Đang vận chuyển",
        "color": Color(0xFF5C2E00),
        "bgColor": Color(0xFFFCF3C5),
        "icon": Icons.two_wheeler,
      },
      "delivered": {
        "text": "Đã hoàn thành",
        "color": Color(0xFF234904),
        "bgColor": Color(0xFFDEFAC2),
        "icon": Icons.check,
      },
      "ready_to_pick": {
        "text": "Đang giao dịch",
        "color": Color(0xFF163369),
        "bgColor": Color(0xFFDEE9FC),
        "icon": Icons.currency_exchange,
      },
      "picking": {
        "text": "Đang giao dịch",
        "color": Color(0xFF163369),
        "bgColor": Color(0xFFDEE9FC),
        "icon": Icons.currency_exchange,
      },
      "returned": {
        "text": "Trả hàng đã nhận",
        "color": Color(0xFF8C000E),
        "bgColor": Color(0xFFFCE1DE),
        "icon": Icons.restart_alt,
      },
      "returning": {
        "text": "Trả hàng chờ nhận",
        "color": Color(0xFF8C000E),
        "bgColor": Color(0xFFFCE1DE),
        "icon": Icons.restart_alt,
      },
    };

    var style =
        statusStyles[status] ??
        {
          "text": "Không xác định",
          "color": Colors.grey,
          "bgColor": Colors.grey.shade300,
          "icon": Icons.help_outline,
        };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: style["bgColor"], borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style["icon"], color: style["color"], size: 16),
          SizedBox(width: 6),
          Text(
            style["text"],
            style: TextStyle(color: style["color"], fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget buildPaymentStatusBadge(String status) {
    Map<String, dynamic> statusStyles = {
      "paid": {
        "text": "Đã thanh toán",
        "color": Color(0xFF234904),
        "bgColor": Color(0xFFDEFAC2),
        "icon": Icons.check, // CheckOutlined
      },
      "partial_payment": {
        "text": "Thanh toán 1 phần",
        "color": Color(0xFFD37E09),
        "bgColor": Color(0xFFFFF6CC),
        "icon": Icons.hourglass_bottom, // HourglassBottomOutlined
      },
      "unpaid": {
        "text": "Chưa thanh toán",
        "color": Color(0xFF80000E),
        "bgColor": Color(0xFFFCE1DE),
        "icon": Icons.report, // ReportOutlined
      },
      "refund": {
        "text": "Hoàn tiền",
        "color": Color(0xFF80000E),
        "bgColor": Color(0xFFFCE1DE),
        "icon": Icons.report, // ReportOutlined
      },
    };

    var style =
        statusStyles[status] ??
        {
          "text": "Không xác định",
          "color": Colors.grey,
          "bgColor": Colors.grey.shade300,
          "icon": Icons.help_outline,
        };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: style["bgColor"], borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style["icon"], color: style["color"], size: 16),
          SizedBox(width: 6),
          Text(
            style["text"],
            style: TextStyle(color: style["color"], fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
