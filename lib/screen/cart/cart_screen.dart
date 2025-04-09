import 'package:flutter/material.dart';
import 'package:mobile/model/cart_item.dart';
import 'package:mobile/model/customer.dart';
import 'package:mobile/providers/cart_provider.dart';
import 'package:mobile/providers/invoice_provider.dart';
import 'package:mobile/screen/cart/payment_screen.dart';
import 'package:mobile/screen/customer/search_select.dart';
import 'package:mobile/screen/home_screen.dart';
import 'package:mobile/screen/product/product_screen.dart';
import 'package:mobile/service/api_service.dart';
import 'package:mobile/widget/create_custumer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedCustomer;
  const CartScreen({Key? key, this.selectedCustomer}) : super(key: key);
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, Map<String, dynamic>> productDetails = {};
  String selectedWarehouse = "Thợ Nhuộm";
  List<String> warehouseList = ['Thợ Nhuộm', 'Terra'];
  Map<String, dynamic>? selectedCustomer;
  double _discount = 0;
  String _discountType = "%";
  String userId = "NV123";
  void loadUserId() async {
    String? id = await getUserId();
    if (id != null) {
      setState(() {
        userId = id;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
    loadUserId();
    selectedCustomer = widget.selectedCustomer;
    _saveCustomerDetails();
  }

  Future<void> _fetchProductDetails() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    for (var item in cartProvider.cartItems) {
      if (!productDetails.containsKey(item.productId)) {
        final product = await ApiService.getProductDetail(item.productId);
        if (product != null) {
          setState(() {
            productDetails[item.productId] = product;
          });
        }
      }
    }
  }

  Future<void> _saveCustomerDetails() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
      final List<Item> cartItems = cartProvider.cartItems;
      if (cartItems.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Vui lòng chọn sản phẩm để tiếp tục!')));
        return;
      }
      final customerId = selectedCustomer != null ? selectedCustomer!["id"] : "";
      final Map<String, dynamic> customerData = {
        "customer_id": customerId,
        "user_id": "NV2",
        "branch": selectedWarehouse,
        "discount": _discount,
        "discount_type": _discountType,
        "is_delivery": true,
        "expected_delivery": "",
        "order_source": "facebook",
        "note": "",
        "items": cartItems.map((item) => item.toJson()).toList(),
        "service_items": [],
        "extraCost": 0,
      };
      invoiceProvider.updateInvoice(customerData);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Thêm đơn hàng thành công')));
      Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void clearSelectedCustomer() {
    setState(() {
      selectedCustomer = null;
    });
  }

  Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("id");
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: statusBarHeight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, size: 24, color: Colors.black),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF338BFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isDense: true,
                    value: selectedWarehouse,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedWarehouse = newValue!;
                      });
                    },
                    items:
                        warehouseList.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              "Kho ${value}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                    dropdownColor: Color(0xFF338BFF),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 0.1, color: const Color(0xFF555E5C).withOpacity(0.3)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tạo Đơn Hàng", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.delete, size: 24, color: Colors.red),
                  onPressed: () {
                    cartProvider.clearCart();
                    clearSelectedCustomer();
                  },
                ),
              ],
            ),
          ),
          Container(height: 16, color: Color(0xFFF2F2F7)),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                final formData = CustomerFormData();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => Scaffold(
                          body: Column(
                            children: [
                              SizedBox(height: statusBarHeight),
                              _buildHeader(
                                context,
                                formData,
                                onCreated: (customer) {
                                  setState(() {
                                    selectedCustomer = customer;
                                  });
                                },
                              ),
                              GestureDetector(
                                onTap: () async {
                                  Map<String, dynamic>? response = await ApiService.getCustomers(
                                    0,
                                    20,
                                  );
                                  if (response != null && response.containsKey('customers')) {
                                    List<Map<String, dynamic>> danhSachKhachHang =
                                        List<Map<String, dynamic>>.from(response['customers']);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => SearchSelect(customers: danhSachKhachHang),
                                      ),
                                    );
                                  } else {
                                    print("⚠️ Không thể tải danh sách khách hàng!");
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEFEFF4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.search, color: Colors.black54, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        "Tìm kiếm khách hàng",
                                        style: TextStyle(color: Colors.black54, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(child: CreateCustomerBody(form: formData)),
                            ],
                          ),
                        ),
                  ),
                );
              },
              child:
                  selectedCustomer == null
                      ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "Chọn khách hàng",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      : ListTile(
                        title: Row(
                          children: [
                            Text(selectedCustomer?['full_name'] ?? "Không có tên"),
                            Spacer(), // Đẩy nút X về bên phải
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.black), // Nút X
                              onPressed: clearSelectedCustomer,
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("SĐT: ${selectedCustomer?['phone'] ?? 'Không có'}"),
                            Text(
                              "Công nợ: ${selectedCustomer?['debt'] ?? '0'} · Điểm tích lũy: ${selectedCustomer?['loyalty_points'] ?? '0'}",
                            ),
                          ],
                        ),
                      ),
            ),
          ),
          Expanded(
            child:
                cartItems.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/cart.png'),
                          SizedBox(height: 20),
                          Text(
                            'Không có sản phẩm nào trong đơn hàng',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProductScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Color(0xFF338BFF), width: 1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: Text(
                              'Chọn sản phẩm',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF338BFF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final product = productDetails[item.productId];
                        return Card(
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                product != null
                                    ? Image.network(
                                      "https://api.mediax.com.vn${product["images"].isNotEmpty ? product["images"][0]["url"] : "/static/default.png"}",
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                    : SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Center(child: CircularProgressIndicator()),
                                    ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      product != null
                                          ? Text(
                                            product['name'] ?? "Không có tên sản phẩm",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                          : SizedBox(
                                            height: 20,
                                            width: 100,
                                            child: LinearProgressIndicator(),
                                          ),
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          product != null
                                              ? Text(
                                                "Giá: ${product["price_retail"] ?? "0"}",
                                                style: TextStyle(fontSize: 15, color: Colors.blue),
                                              )
                                              : SizedBox(
                                                height: 16,
                                                width: 60,
                                                child: LinearProgressIndicator(),
                                              ),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey.shade400),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            height: 30,
                                            width: 120,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      if (item.quantity > 1) {
                                                        cartProvider.updateQuantity(
                                                          item.productId,
                                                          item.quantity - 1,
                                                        );
                                                      }
                                                    },
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.remove,
                                                        size: 18,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(width: 1, color: Colors.grey.shade300),
                                                Expanded(
                                                  child: TextField(
                                                    controller: TextEditingController(
                                                      text: item.quantity.toString(),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    keyboardType: TextInputType.number,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      enabledBorder: InputBorder.none,
                                                      focusedBorder: InputBorder.none,
                                                      isCollapsed: true,
                                                      contentPadding: EdgeInsets.zero,
                                                    ),
                                                    onChanged: (value) {
                                                      final newQuantity = int.tryParse(value);
                                                      if (newQuantity != null && newQuantity > 0) {
                                                        cartProvider.updateQuantity(
                                                          item.productId,
                                                          newQuantity,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                                Container(width: 1, color: Colors.grey.shade300),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      cartProvider.updateQuantity(
                                                        item.productId,
                                                        item.quantity + 1,
                                                      );
                                                    },
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 18,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Chiết khấu tổng đơn ",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xB23C3C43),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _discountType,
                              icon: SizedBox.shrink(),
                              items:
                                  ["%", "value"].map((String type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(
                                        "(${type == '%' ? '%' : 'VND'})",
                                        style: TextStyle(fontSize: 14, color: Color(0xFF338BFF)),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _discountType = newValue!;
                                });
                                cartProvider.updateDiscount(_discount, _discountType);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 70,
                      height: 28,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0x593C3C43), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "0",
                          suffixText: _discountType == "%" ? "%" : "",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _discount = double.tryParse(value) ?? 0;
                          });
                          cartProvider.updateDiscount(_discount, _discountType);
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tổng đơn hàng (${cartProvider.totalQuantity().toString()} sản phẩm ) :",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "${cartProvider.totalPrice()}",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _saveCustomerDetails();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Center(
                    child: Text("Thanh toán", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    CustomerFormData formData, {
    required Function(Map<String, dynamic> customer) onCreated,
  }) {
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
              TextButton(
                onPressed: () async {
                  if (formData.formKey.currentState!.validate() ?? false) {
                    final payload = {
                      "full_name": formData.nameController.text,
                      "date_of_birth": formData.selectedDate?.toIso8601String().split('T').first,
                      "debt": formData.debtController.text,
                      "phone": formData.phoneController.text,
                      "email": formData.emailController.text,
                      "address": formData.addressController.text,
                      "group_id": formData.selectedGroupId,
                      "province": formData.selectedProvince,
                      "district": formData.selectedDistrict,
                      "ward": formData.selectedWard,
                    };
                    // print(payload);
                    try {
                      final createdCustomer = await ApiService.createCustomer(payload);
                      print(payload);
                      onCreated(createdCustomer);
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF338BFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: const Text("Tạo khách hàng", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text("Tạo Khách Hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
