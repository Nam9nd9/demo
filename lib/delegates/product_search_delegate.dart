import 'package:flutter/material.dart';
import 'package:mobile/screen/product/detail_screen.dart';
import 'package:mobile/service/api_service.dart';

class ProductSearchDelegate extends SearchDelegate<String> {
  Future<List<Map<String, dynamic>>> _searchProducts(String query) async {
    if (query.isEmpty) return [];
    return await ApiService.searchProduct(query);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => close(context, ""),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildProductList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildProductList();
  }

  Widget _buildProductList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchProducts(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print("⚠️ Lỗi khi tải dữ liệu: ${snapshot.error}");
          return const Center(child: Text("Lỗi khi tải dữ liệu"));
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Center(child: Text("Không tìm thấy sản phẩm nào"));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          itemCount: products.length,
          separatorBuilder: (_, __) => Divider(height: 0.5, color: const Color(0xFF555E5C).withOpacity(0.3)),
          itemBuilder: (context, index) {
            final product = products[index];

            final String name = product['name'] ?? 'Không có tên';
            final String description = product['description'] ?? 'Không có mô tả';
            final String price = product['price_retail']?.toString() ?? 'Chưa có giá';
            final String barcode = product['barcode'] ?? 'Không có mã vạch';
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
              onTap: () async {
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
      },
    );
  }
}
