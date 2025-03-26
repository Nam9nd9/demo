import 'package:flutter/material.dart';
import 'package:mobile/screen/product/detail_screen.dart';
import 'package:mobile/service/api_service.dart';

class ProductSearchPage extends StatefulWidget {
  @override
  _ProductSearchPageState createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = false;
  String query = "";

  void _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        products = [];
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = true);
    try {
      final result = await ApiService.searchProduct(query);
      setState(() {
        products = result;
      });
    } catch (error) {
      print("⚠️ Lỗi khi tải dữ liệu: $error");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: _buildSearchField(),
      ),
      body: _buildProductList(),
    );
  }

Widget _buildSearchField() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Tìm kiếm sản phẩm ...",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      onChanged: (text) {
        setState(() => query = text);
        _searchProducts(text);
      },
    ),
  );
}

  Widget _buildProductList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty && query.isNotEmpty) {
      return const Center(child: Text("Không tìm thấy sản phẩm nào"));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      itemCount: products.length,
      separatorBuilder: (_, __) => Divider(height: 0.5, color: Colors.grey.withOpacity(0.3)),
      itemBuilder: (context, index) {
        final product = products[index];

        final String name = product['name'] ?? 'Không có tên';
        final String price = product['price_retail']?.toString() ?? 'Chưa có giá';
        final int quantity = product['thonhuom_can_sell'] ?? 0;
        final int stock = product['terra_can_sell'] ?? 0;

        final List images = product['images'] ?? [];
        final String imageUrl = (images.isNotEmpty && images[0] != null)
            ? "https://api.mediax.com.vn${images[0]['url']}"
            : ''; 

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                )
              : const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Giá: $price\n",
                      style: const TextStyle(fontSize: 15, color: Color(0xFF338BFF), fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: "Thợ nhuộm: ", style: TextStyle(color: Color(0xB23C3C43))),
                    TextSpan(text: "$quantity ", style: const TextStyle(fontWeight: FontWeight.w600)),
                    const TextSpan(text: " . Terra: ", style: TextStyle(color: Color(0xB23C3C43))),
                    TextSpan(text: "$stock", style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(productId: product['id']),
              ),
            );
          },
        );
      },
    );
  }
}
