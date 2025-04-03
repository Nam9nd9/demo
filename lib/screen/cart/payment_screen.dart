import 'package:flutter/material.dart';
import 'package:mobile/screen/cart/invoiceInfo_screen.dart';
import 'package:mobile/service/api_service.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/cart_provider.dart'; // Import đúng đường dẫn của CartProvider
import 'package:mobile/providers/invoice_provider.dart'; // Import InvoiceProvider

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String depositMethod = '';
  TextEditingController _depositController = TextEditingController();

  Future<void> processPayment(
    BuildContext context,
    InvoiceProvider invoiceProvider,
    TextEditingController depositController,
  ) async {
    double deposit = double.tryParse(depositController.text) ?? 0;
    invoiceProvider.updateDepositMethod('cash');
    invoiceProvider.updateDeposit(deposit);
    print(invoiceProvider.toJson());

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
      print("Lỗi khi gọi API: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi khi tạo hóa đơn")));
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
                    ? _buildBankPayment()
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
            });
          },
          title: Text('Chuyển Khoản', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          trailing: Icon(Icons.arrow_forward_ios, size: 18),
        ),
      ],
    );
  }

  Widget _buildBankPayment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chuyển Khoản:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Image.asset('assets/images/splash.png')),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {},
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

  Widget _buildCashPayment(InvoiceProvider invoiceProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tiền Mặt:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
