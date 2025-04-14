import 'package:flutter/material.dart';
import 'package:mobile/screen/account/login_screen.dart';
import 'package:mobile/screen/product/detail_screen.dart';
import 'package:mobile/service/api_service.dart';
import 'package:mobile/widget/advancedDropdownButton.dart';
import 'package:mobile/widget/cart_icon.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/widget/product_search.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String _selectedStatus = 'all';
  final Map<String, String> _statusOptions = {
    'all': 'Tất cả',
    'cotheban': 'Đang giao dịch',
    'ngungban': 'Ngưng giao dịch',
  };

  List<Map<String, dynamic>> _products = [];

  int currentPage = 0;
  final int pageSize = 10;
  bool isLoading = false;
  bool hasMoreData = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
        hasMoreData) {
      fetchProducts();
    }
  }

  Future<void> fetchProducts() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final response = await ApiService.getProducts(currentPage * pageSize, pageSize);
    if (response != null && response["products"] != null) {
      List<dynamic> rawProducts = response["products"];

      // Lọc theo dry_stock
      if (_selectedStatus == 'cotheban') {
        rawProducts = rawProducts.where((p) => p["dry_stock"] == true).toList();
      } else if (_selectedStatus == 'ngungban') {
        rawProducts = rawProducts.where((p) => p["dry_stock"] == false).toList();
      }

      List<Map<String, dynamic>> newProducts =
          rawProducts.map<Map<String, dynamic>>((product) {
            return {
              "image":
                  "https://api.mediax.com.vn${product["images"].isNotEmpty ? product["images"][0]["url"] : "/static/default.png"}",
              "id": product["id"]?.toString() ?? "unknown",
              "name": product["name"] ?? "Không có tên",
              "price": product["price_retail"] ?? 0,
              "quantity": product["thonhuom_can_sell"] ?? 0,
              "stock": product["terra_can_sell"] ?? 0,
            };
          }).toList();

      setState(() {
        if (newProducts.length < pageSize) {
          hasMoreData = false;
        }
        _products.addAll(newProducts);
        currentPage++;
      });
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Phiên đăng nhập hết hạn"),
              content: const Text("Vui lòng đăng nhập lại để tiếp tục sử dụng ứng dụng."),
              actions: [
                TextButton(
                  child: const Text("Xác nhận"),
                  onPressed: () async {
                    await ApiService.signout();
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: statusBarHeight),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sản phẩm", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        try {
                          List<Map<String, dynamic>> products = await ApiService.searchProduct("");
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProductSearchPage()),
                          );
                        } catch (error) {
                          print("⚠️ Lỗi khi tải dữ liệu: $error");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Không thể tải dữ liệu, thử lại sau!")),
                          );
                        }
                      },
                    ),
                    CartIcon(),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: AdvancedDropdownButton(
              items: _statusOptions,
              hint:
                  _selectedStatus == 'cotheban'
                      ? 'Đang giao dịch'
                      : _selectedStatus == 'ngungban'
                      ? 'Ngưng giao dịch'
                      : 'Tất cả',

              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                  _products.clear();
                  currentPage = 0;
                  hasMoreData = true;
                });
                fetchProducts();
              },
            ),
          ),
          const SizedBox(height: 6),
          Divider(height: 0.5, color: const Color(0xFF555E5C).withOpacity(0.3)),
          Expanded(
            child:
                _products.isEmpty && isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      itemCount: _products.length + (hasMoreData ? 1 : 0),
                      separatorBuilder:
                          (_, __) => Column(
                            children: [
                              const SizedBox(height: 10),
                              Divider(height: 0.5, color: const Color(0xFF555E5C).withOpacity(0.3)),
                            ],
                          ),
                      itemBuilder: (context, index) {
                        if (index == _products.length) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final product = _products[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            leading: Image.network(
                              product['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              product['name'],
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 12, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: "Giá: ${product['price']}\n",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF338BFF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: "Thợ nhuộm: ",
                                    style: TextStyle(color: Color(0xB23C3C43)),
                                  ),
                                  TextSpan(
                                    text: "${product['quantity']} ",
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const TextSpan(
                                    text: " . Terra: ",
                                    style: TextStyle(color: Color(0xB23C3C43)),
                                  ),
                                  TextSpan(
                                    text: "${product['stock']}",
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailScreen(productId: product['id']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
