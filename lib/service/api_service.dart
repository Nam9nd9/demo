import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl = "https://api.mediax.com.vn";

  static Future<void> _saveUserData(Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("id", data["id"]);
    await prefs.setString("username", data["username"]);
    await prefs.setString("accessToken", data["access_token"]);
  }

  static Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }

  static Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("id");
  }

  static Future<String?> signin(String username, String password) async {
    const String apiUrl = "$baseUrl/users/signin";
    final Map<String, String> body = {"username": username, "password": password};

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(data);
        await _saveUserData(data);

        return null;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return errorData['detail'];
      }
    } catch (e) {
      print("Lỗi API signin: $e");
      return "Lỗi kết nối với máy chủ!";
    }
  }

  static Future<void> signout() async {
    const String apiUrl = "$baseUrl/users/signout";

    try {
      String? accessToken = await getAccessToken();
      print("🔍 Token hiện tại trước khi đăng xuất: $accessToken");

      if (accessToken == null) {
        print("⚠️ Không tìm thấy accessToken. Vui lòng đăng nhập lại.");
        return;
      }

      final response = await http.post(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove("accessToken");
      } else {
        print("❌ Lỗi khi đăng xuất: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Lỗi API signout: $e");
    }
  }

  // API Get Products
  static Future<Map<String, dynamic>?> getProducts(int skip, int limit) async {
    final String apiUrl = "$baseUrl/products/products?skip=$skip&limit=$limit";
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      print("⚠️ Không có accessToken, cần đăng nhập!");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);
        return jsonDecode(utf8DecodedBody);
      } else {
        print("❌ Lỗi API: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getProductDetail(String id) async {
    final String apiUrl = "$baseUrl/products/product/$id";
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      print("⚠️ Không có accessToken, cần đăng nhập!");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);
        print(utf8DecodedBody);
        return jsonDecode(utf8DecodedBody);
      } else {
        print("❌ Lỗi API: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> searchProduct(
    String query, {
    int skip = 0,
    int limit = 10,
  }) async {
    final String apiUrl = "$baseUrl/products/products?skip=$skip&limit=$limit&search=$query";
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      print("⚠️ Không có accessToken, cần đăng nhập!");
      return [];
    }

    try {
      final response = await http
          .get(
            Uri.parse(apiUrl),
            headers: {"Content-Type": "application/json", "Authorization": "Bearer $accessToken"},
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(data['products']);
      } else {
        print("❌ API lỗi: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
      return [];
    }
  }

  //customer

  static Future<Map<String, dynamic>?> getCustomers(int skip, int limit) async {
    final String apiUrl = "$baseUrl/customers/customers?skip=$skip&limit=$limit";
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      print("⚠️ Không có accessToken, cần đăng nhập!");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);
        return jsonDecode(utf8DecodedBody);
      } else {
        print("❌ Lỗi API: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> payload) async {
    String? accessToken = await getAccessToken();
    final uri = Uri.parse("$baseUrl/customers/customers");

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $accessToken"},
        body: json.encode(payload),
      );

      final String utf8DecodedBody = utf8.decode(response.bodyBytes);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(utf8DecodedBody);
      } else {
        try {
          final Map<String, dynamic> errorData = jsonDecode(utf8DecodedBody);
          throw errorData;
        } catch (_) {
          throw {"error": utf8DecodedBody};
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getCustomerGroups({
    int skip = 0,
    int limit = 10,
    String? query,
  }) async {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      print("⚠️ Không có accessToken, cần đăng nhập!");
      return null;
    }

    String url = "$baseUrl/customers/groups?limit=$limit&skip=$skip";
    if (query != null && query.isNotEmpty) {
      url += "&search=${Uri.encodeComponent(query)}";
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        return jsonDecode(utf8DecodedBody);
      } else {
        print("❌ API lỗi: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCustomerById(String customerId) async {
    final String apiUrl = "$baseUrl/customers/customers/${customerId}";
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      print("⚠️ Không có accessToken, cần đăng nhập!");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);
        return jsonDecode(utf8DecodedBody);
      } else {
        print("❌ API Error: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}");
        return null;
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
      return null;
    }
  }

  static Future<bool> updateCustomer(String customerId, Map<String, dynamic> updatedData) async {
    final String apiUrl = "$baseUrl/customers/customers/$customerId";
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      print("⚠️ Không có accessToken, cần đăng nhập!");
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $accessToken"},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        print("✅ Cập nhật khách hàng thành công!");
        return true;
      } else {
        print("❌ Lỗi API: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
      return false;
    }
  }

  //invoice
  static Future<dynamic> createInvoice(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/invoices/invoices');
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      print("⚠️ Không có accessToken, cần đăng nhập!");
      throw Exception("Chưa đăng nhập");
    }

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $accessToken"},
        body: jsonEncode(payload),
      );

      final String utf8DecodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(utf8DecodedBody);
      } else {
        try {
          final Map<String, dynamic> errorData = jsonDecode(utf8DecodedBody);
          throw errorData;
        } catch (_) {
          throw {"error": utf8DecodedBody};
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchInvoiceDetail(String invoiceId) async {
    final String url = "${baseUrl}/invoices/invoices/$invoiceId";
    String? accessToken = await getAccessToken();

    final response = await http.get(
      Uri.parse(url),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $accessToken"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final String utf8DecodedBody = utf8.decode(response.bodyBytes);
      return jsonDecode(utf8DecodedBody);
    } else {
      throw Exception("Lỗi khi lấy thông tin hóa đơn");
    }
  }

  static Future<List<Map<String, dynamic>>?> getProvinces() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/deliveries/ghn/provinces'));

      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonData = jsonDecode(utf8DecodedBody);

        if (jsonData['success'] == true && jsonData['data'] is List) {
          return List<Map<String, dynamic>>.from(jsonData['data']);
        } else {
          print("⚠️ Dữ liệu API Tỉnh không hợp lệ: $jsonData");
        }
      } else {
        print("❌ Lỗi API: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}");
      }
    } catch (e) {
      print("⚠️ Lỗi khi gọi API: $e");
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>?> getDistricts(String provinceId) async {
    final String apiUrl = "$baseUrl/deliveries/ghn/districts/$provinceId";
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      print("⚠️ Không có accessToken, cần đăng nhập!");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = jsonDecode(utf8DecodedBody);

        if (data.containsKey('data') && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          print("⚠️ Dữ liệu API Huyện không hợp lệ: $data");
        }
      } else {
        print("❌ Lỗi API: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}");
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>?> getWards(String districtId) async {
    final String apiUrl = "$baseUrl/deliveries/ghn/wards/$districtId";
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      print("⚠️ Không có accessToken, cần đăng nhập!");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        final String utf8DecodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = jsonDecode(utf8DecodedBody);

        if (data.containsKey('data') && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          print("⚠️ Dữ liệu API Phường không hợp lệ: $data");
        }
      } else {
        print("❌ Lỗi API: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}");
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối API: $e");
    }
    return null;
  }
}
