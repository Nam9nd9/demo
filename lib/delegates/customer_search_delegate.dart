import 'package:flutter/material.dart';

class CustomerSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> customers;
  final TextEditingController _textEditingController = TextEditingController();

  CustomerSearchDelegate(this.customers) {
    _textEditingController.addListener(() {
      query = _textEditingController.text;
      showSuggestions(_context!);
    });
  }

  BuildContext? _context;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _textEditingController.clear();
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
  String get searchFieldLabel => "Tìm kiếm khách hàng...";

  @override
  Widget buildSearchField(BuildContext context) {
    _context = context;
    return TextField(
      controller: _textEditingController,
      autofocus: true,
      decoration: InputDecoration(
        prefixIcon: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => close(context, ""),
        ),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _textEditingController.clear();
                  query = "";
                  showSuggestions(context);
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildCustomerList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildCustomerList();
  }

  Widget _buildCustomerList() {
    final filteredCustomers = customers
        .where((c) => c['full_name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (filteredCustomers.isEmpty) {
      return const Center(child: Text("Không tìm thấy khách hàng nào"));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      itemCount: filteredCustomers.length,
      separatorBuilder: (_, __) => Divider(
        height: 0.5,
        color: const Color(0xFF555E5C).withOpacity(0.3),
      ),
      itemBuilder: (context, index) {
        final customer = filteredCustomers[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            customer['full_name'] ?? "Không có tên",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            "SĐT: ${customer['phone'] ?? 'Không có'}",
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {
            // Xử lý khi chọn khách hàng
          },
        );
      },
    );
  }
}
