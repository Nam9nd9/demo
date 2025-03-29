import 'package:flutter/material.dart';
import 'package:mobile/screen/cart/cart_screen.dart';
import 'package:mobile/screen/customer/detail_screen.dart';

class SearchSelect extends StatefulWidget {
  final List<Map<String, dynamic>> customers;

  const SearchSelect({Key? key, required this.customers}) : super(key: key);

  @override
  _SearchSelect createState() => _SearchSelect();
}

class _SearchSelect extends State<SearchSelect> {
  String _query = "";
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: _buildSearchField(context),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Danh sách khách hàng",
                style: TextStyle(
                    fontSize: 15,
                    color: Color(0xB23C3C43),
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(child: _buildCustomerList()), 
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: "Tìm kiếm khách hàng...",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE9ECF2)), // Màu viền #E9ECF2
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE9ECF2)), // Khi chưa focus
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE9ECF2)), // Khi focus
          ),
          prefixIcon: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _query = "";
                      _searchController.clear();
                    });
                  },
                )
              : null,
        ),
        onChanged: (text) {
          setState(() {
            _query = text;
          });
        },
      ),
    );
  }

  Widget _buildCustomerList() {
    final filteredCustomers = widget.customers
        .where((c) => c['full_name'].toLowerCase().contains(_query.toLowerCase()))
        .toList();

    if (filteredCustomers.isEmpty) {
      return const Center(child: Text("Không tìm thấy khách hàng nào"));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredCustomers.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final customer = filteredCustomers[index];
        return ListTile(
          title: Text(customer['full_name'] ?? "Không có tên"),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SĐT: ${customer['phone'] ?? 'Không có'}"),
              Text("Công nợ: ${customer['debt'] ?? '0'} · Điểm tích lũy: ${customer['loyalty_points'] ?? '0'}"),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartScreen(
                  selectedCustomer: customer,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
