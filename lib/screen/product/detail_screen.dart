import 'package:flutter/material.dart';
import 'package:mobile/providers/cart_provider.dart';
import 'package:mobile/screen/cart/cart_screen.dart';
import 'package:mobile/service/api_service.dart';
import 'package:mobile/widget/advancedDropdownButton.dart';
import 'package:mobile/widget/cart_icon.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? productDetail;
  bool isLoading = true;
  String selectedWarehouse = "thonhuom";
  int quantity = 0; 
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: quantity.toString());
    fetchProductDetail();
  }
  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
  
  void updateQuantity(int newQuantity) {
    int maxStock = productDetail?["${selectedWarehouse}_stock"] ?? 0;

    if (newQuantity < 0) return;

    if (newQuantity > maxStock) {
    newQuantity = maxStock;
  }
    setState(() {
      quantity = newQuantity;
      _quantityController.text = quantity.toString();
    });
  }

  Future<void> fetchProductDetail() async {
    final data = await ApiService.getProductDetail(widget.productId);
    setState(() {
      productDetail = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      body:Column(
        children: [
          SizedBox(height: statusBarHeight),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                    CartIcon(),
                  
                
              ],
            ),
          ),
          Expanded(child: isLoading
          ? Center(child: CircularProgressIndicator())
          : productDetail == null
              ? Center(child: Text("Không có dữ liệu"))
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            productDetail!["images"] != null && productDetail!["images"].isNotEmpty
                                ? Image.network(
                                    "https://api.mediax.com.vn${productDetail!["images"][0]["url"]}",
                                    height: 54,
                                    fit: BoxFit.cover,
                                  )
                                : Text("Không có ảnh"),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                productDetail!["name"],
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                softWrap: true,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                                      
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Tồn kho", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            AdvancedDropdownButton(
                              hint: "Chọn kho", 
                              items: {
                                "thonhuom": "Kho Thợ Nhuộm",
                                "terra": "Kho Tera"
                              },
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedWarehouse = newValue!;
                                });
                              },
                              customStyle: true,
                            ),
                          ],
                        ),
                          
                        SizedBox(height: 10),
                        _buildDetailRow("Tồn kho", productDetail!["${selectedWarehouse}_stock"].toString()),
                        _buildDetailRow("Có thể bán", productDetail!["${selectedWarehouse}_can_sell"].toString()),
                        _buildDetailRow("Hàng đang về", productDetail!["pending_arrival_${selectedWarehouse}"].toString()),
                        _buildDetailRow("Hàng đang giao", productDetail!["out_for_delivery_${selectedWarehouse}"].toString()),
                        SizedBox(height: 40),
                      Text("Thông tin sản phẩm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      _buildDetailRow("Mã sản phẩm", productDetail!["id"]),
                      _buildDetailRow("Mã barcode", productDetail!["barcode"] ?? "Không có"),
                      _buildDetailRow("Khối lượng", "${productDetail!["weight"]} g"),
                      _buildDetailRow("Loại sản phẩm", productDetail!["group_name"] ?? "Không có"),
                      _buildDetailRow("Nhãn hiệu", productDetail!["brand"] ?? "Không có"),
                      _buildDetailRow("Giá bán lẻ", productDetail!["price_retail"].toString() ?? "Không có"),
                      _buildDetailRow("Hạn sử dụng", productDetail!["expiration_date"] ?? "Không có"),
                      _buildDetailRow("Ngày tạo", productDetail!["created_at"] ?? "Không có"),
                    
                      ],
                    ),
                  ),
                ),)
        ],
      ) ,
      bottomNavigationBar: BottomAppBar(
        color:Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          height: 60,
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                _showQuantityModal(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF338BFF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Thêm vào đơn hàng",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Color(0xB23C3C43), fontSize: 15, fontWeight: FontWeight.w400)),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 0.5,
          color: Color(0x5C555E5C),
          width: double.infinity,
        ),
      ],
    );
  }

void _showQuantityModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          double price = double.tryParse(productDetail!["price_retail"].toString()) ?? 0;
          double totalPrice = price * quantity;
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // <-- Đẩy nội dung lên khi mở bàn phím
            ),
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)), // Bo góc trên
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(16.0), 
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: productDetail!["images"] != null && productDetail!["images"].isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage("https://api.mediax.com.vn${productDetail!["images"][0]["url"]}"),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: Colors.grey[200], 
                            ),
                            child: productDetail!["images"] == null || productDetail!["images"].isEmpty
                                ? Center(child: Icon(Icons.image_not_supported, color: Colors.grey))
                                : null,
                            // color: Colors.grey[200],
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${totalPrice.toStringAsFixed(0)}",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Có thể bán: ${productDetail?["${selectedWarehouse}_stock"] ?? 0}", // Lấy giá trị tồn kho từ productDetail
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    // SizedBox(width: 12),
                                    // Expanded(
                                    //   child: DropdownButtonFormField<String>(
                                    //     value: selectedWarehouse,
                                    //     decoration: InputDecoration(
                                    //       filled: true,
                                    //       fillColor: Color.fromARGB(51, 41, 126, 238),
                                    //       border: OutlineInputBorder(
                                    //         borderRadius: BorderRadius.circular(6),
                                    //         borderSide: BorderSide.none,
                                    //       ),
                                    //       contentPadding: EdgeInsets.fromLTRB(10, 6, 8, 6),
                                    //       isDense: true,
                                    //     ),
                                    //     icon: Icon(Icons.arrow_drop_down, color: Color(0xFF338BFF)),
                                    //     iconSize: 12,
                                    //     onChanged: (String? newValue) {
                                    //       setState(() {
                                    //         selectedWarehouse = newValue!;
                                    //       });
                                    //     },
                                    //     items: [
                                    //       DropdownMenuItem(
                                    //         value: "thonhuom",
                                    //         child: Text("Kho thợ Nhuộm", style: TextStyle(fontSize: 12, color: Color(0xFF338BFF))),
                                    //       ),
                                    //       DropdownMenuItem(
                                    //         value: "terra",
                                    //         child: Text("Kho Tera", style: TextStyle(fontSize: 12, color: Color(0xFF338BFF))),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                                SizedBox(height: 9),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
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
                                                if (quantity > 1) {
                                                  setState(() {
                                                    updateQuantity(quantity - 1);
                                                  });
                                                }
                                              },
                                              child: Center(
                                                child: Icon(Icons.remove, size: 18, color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            color: Colors.grey.shade300,
                                          ),
                                          Expanded(
                                            child: TextField(
                                              controller: _quantityController,
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
                                                  setState(() {
                                                    updateQuantity(newQuantity);
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            color: Colors.grey.shade300,
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  updateQuantity(quantity + 1);
                                                });
                                              },
                                              child: Center(
                                                child: Icon(Icons.add, size: 18, color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.start,
                                //   children: [
                                //     Row(
                                //       mainAxisAlignment: MainAxisAlignment.center,
                                //       children: [
                                //         Container(
                                //           decoration: BoxDecoration(
                                //             border: Border.all(color: Colors.grey),
                                //             borderRadius: BorderRadius.circular(4),
                                //           ),
                                //           child: Row(
                                //             children: [
                                //               IconButton(
                                //                 icon: Icon(Icons.remove, size: 16),
                                //                 onPressed: () {
                                //                   if (quantity > 1) {
                                //                     setState(() {
                                //                       updateQuantity(quantity -1);
                                //                     });
                                //                   }
                                //                 },
                                //               ),
                                //               Container(
                                //                 width: 55,                                               
                                //                 child: TextField(
                                //                   controller: _quantityController,
                                //                   textAlign: TextAlign.center,
                                //                   keyboardType: TextInputType.number,
                                //                   decoration: InputDecoration(
                                //                     border: InputBorder.none,
                                //                   ),
                                //                   onChanged: (value) {
                                //                     int? newQuantity = int.tryParse(value);
                                //                     if (newQuantity != null) {
                                //                       setState(() {
                                //                         updateQuantity(newQuantity);
                                //                       });
                                //                     }
                                //                   },
                                //                 ),
                                //               ),
                                //               IconButton(
                                //                 icon: Icon(Icons.add, size: 16),
                                //                 onPressed: () {
                                //                   setState(() {
                                //                     updateQuantity(quantity +1);
                                //                   });
                                //                 },
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                    //   ElevatedButton(
                    //     onPressed: () {
                    //       _addToOrder(context);
                    //       Navigator.pop(context);
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Color(0xFF338BFF),
                    //       foregroundColor: Colors.white,
                    //       padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 15),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     _addToOrder(context);
                    //     Navigator.pop(context);
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Color(0xFF338BFF),
                    //     foregroundColor: Colors.white,
                    //     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //   ),
                    //   SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity, // Button full chiều rộng
                      child: ElevatedButton(
                        onPressed: () {
                          _addToOrder(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF338BFF),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12), // Tăng chiều cao
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Thêm vào đơn hàng",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
          );
        },
      );
    },
  );
}

void _addToOrder(BuildContext context) {
  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  String productId = productDetail!["id"].toString();
  int stock = productDetail?["${selectedWarehouse}_stock"] ?? 0;
  double price = double.tryParse(productDetail?["price_retail"].toString() ?? "0") ?? 0;
  double discount = double.tryParse(productDetail?["discount_price"].toString() ?? "0") ?? 0;
  print(stock);
  if (quantity <= 0 || quantity > stock) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Số lượng không hợp lệ!"))
    );
    return;
  }
  cartProvider.addToCart(productId, quantity, price, discount);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Đã thêm vào đơn hàng!"))
  );
}
}
