import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/utils/error_messages.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile/screen/cart/invoiceInfo_screen.dart';
import 'package:mobile/service/api_service.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/cart_provider.dart';
import 'package:mobile/providers/invoice_provider.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String depositMethod = '';
  TextEditingController _depositController = TextEditingController();
  bool bankTransferConfirmed = false;

  Future<void> processPayment(
    BuildContext context,
    InvoiceProvider invoiceProvider,
    TextEditingController depositController,
  ) async {
    double deposit = double.tryParse(depositController.text) ?? 0;
    invoiceProvider.updateDepositMethod('cash');
    invoiceProvider.updateDeposit(deposit);

    try {
      final response = await ApiService.createInvoice(invoiceProvider.toJson());
      if (response != null && response['id'] != null) {
        String invoiceId = response['id'].toString();
        print("thông tin đơn hàng id : ${invoiceId}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Tạo hóa đơn thành công!")));

        await Future.delayed(Duration(seconds: 2));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InvoiceInfoScreen(invoiceId: invoiceId)),
        );
      }
    } catch (e) {
      print(e);
      String message = "Đã xảy ra lỗi";
      if (e is Map<String, dynamic> && e["error"] != null) {
        String errorString = e["error"];
        final errorCode = jsonDecode(errorString);
        message = getErrorMessage(errorCode["detail"]);
      } else if (e is Exception) {
        // Nếu là exception có chứa chuỗi JSON lỗi
        try {
          final errorData = jsonDecode(e.toString());
          if (errorData is Map && errorData["error"] != null) {
            String errorCode = errorData["error"];
            message = getErrorMessage(errorCode);
          }
        } catch (_) {}
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: statusBarHeight),
          _buildHeader(context),
          Container(height: 16, color: Color(0xFFF2F2F7)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                depositMethod == 'cash'
                    ? _buildCashPayment(invoiceProvider)
                    : depositMethod == 'bank'
                    ? (bankTransferConfirmed
                        ? _buildBankTransferAsCash(invoiceProvider)
                        : _buildBankPayment())
                    : _buildPaymentOptions(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn phương thức thanh toán:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10),
        ListTile(
          onTap: () {
            setState(() {
              depositMethod = 'cash';
            });
          },
          title: Text('Tiền Mặt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          trailing: Icon(Icons.arrow_forward_ios, size: 18),
        ),
        Divider(),
        ListTile(
          onTap: () {
            setState(() {
              depositMethod = 'bank';
              bankTransferConfirmed = false;
            });
          },
          title: Text('Chuyển Khoản', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          trailing: Icon(Icons.arrow_forward_ios, size: 18),
        ),
      ],
    );
  }

  Widget _buildBankPayment() {
    // final amount = Provider.of<CartProvider>(context, listen: false).totalPrice();
    // final qrData = generateQRData(amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chuyển Khoản:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 10),
        Center(child: Image.asset('assets/images/splash.png', height: 300)),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            final cartAmount = Provider.of<CartProvider>(context, listen: false).totalPrice();
            _depositController.text = cartAmount.toStringAsFixed(0);
            setState(() {
              bankTransferConfirmed = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Center(
            child: Text("Xác nhận", style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildBankTransferAsCash(InvoiceProvider invoiceProvider) {
    return _buildCashPayment(invoiceProvider);
  }

  Widget _buildCashPayment(InvoiceProvider invoiceProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          depositMethod == 'cash' ? 'Tiền Mặt:' : 'Chuyển Khoản:',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10),
        SizedBox(height: 10),
        Row(
          children: [
            Text('Tiền nhận thực :', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _depositController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: '0,00',
                  labelStyle: TextStyle(
                    color: Color(0xB23C3C43),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            processPayment(context, invoiceProvider, _depositController);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Center(
            child: Text("Xác nhận", style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              if (depositMethod.isEmpty)
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF338BFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Thanh toán sau",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
            ],
          ),
          Text(
            "${cartProvider.totalPrice()}",
            style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // String _tlv(String tag, String value) {
  //   final len = value.length.toString().padLeft(2, '0');
  //   return '$tag$len$value';
  // }

  // String _crc16(String input) {
  //   int crc = 0xFFFF;
  //   for (int i = 0; i < input.length; i++) {
  //     crc ^= input.codeUnitAt(i) << 8;
  //     for (int j = 0; j < 8; j++) {
  //       if ((crc & 0x8000) != 0) {
  //         crc = (crc << 1) ^ 0x1021;
  //       } else {
  //         crc <<= 1;
  //       }
  //     }
  //   }
  //   crc &= 0xFFFF;
  //   return crc.toRadixString(16).padLeft(4, '0');
  // }

  // String generateQRData(double amount) {
  //   final payloadFormat = _tlv("00", "01");
  //   final pointOfInitiationMethod = _tlv("01", "11");

  //   final bankCode = "970407";
  //   final accNumber = "19034362011011";
  //   final name = "MAI THI THAO";
  //   final merchantAccountInfo = _tlv(
  //     "38",
  //     _tlv("00", "A000000727") +
  //         _tlv("01", bankCode) +
  //         _tlv("02", accNumber) +
  //         _tlv("08", name.toUpperCase()),
  //   );

  //   final currencyCode = _tlv("53", "704"); // VND
  //   final transactionAmount = _tlv("54", amount.toStringAsFixed(0));
  //   final countryCode = _tlv("58", "VN");

  //   final data =
  //       payloadFormat +
  //       pointOfInitiationMethod +
  //       merchantAccountInfo +
  //       currencyCode +
  //       transactionAmount +
  //       countryCode;

  //   final crc = _tlv("63", _crc16(data + "6304").toUpperCase());

  //   return data + crc;
  // }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: ChangeNotifierProvider(
        create: (context) => InvoiceProvider(),
        child: MaterialApp(home: PaymentScreen()),
      ),
    ),
  );
}
