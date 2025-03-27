import 'package:flutter/material.dart';
import 'package:mobile/screen/customer/detail_screen.dart';

class CustomerSearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> customers;

  const CustomerSearchPage({Key? key, required this.customers}) : super(key: key);

  @override
  _CustomerSearchPageState createState() => _CustomerSearchPageState();
}

class _CustomerSearchPageState extends State<CustomerSearchPage> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: _buildSearchField(context),
      ),
      body: _buildCustomerList(),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: "Tìm kiếm khách hàng...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          prefixIcon: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
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
      itemCount: filteredCustomers.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final customer = filteredCustomers[index];
        return ListTile(
          title: Text(customer['full_name'] ?? "Không có tên"),
          subtitle: Text("SĐT: ${customer['phone'] ?? 'Không có'}"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerDetailScreen(customerId: customer['id'].toString()),
              ),
            );
          },
        );
      },
    );
  }
}
