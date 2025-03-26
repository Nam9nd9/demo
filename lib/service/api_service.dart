import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl = "https://api.mediax.com.vn";

  // Lưu accessToken vào SharedPreferences
  static Future<void> _saveAccessToken(String accessToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", accessToken);
  }

  // Lấy accessToken từ SharedPreferences
  static Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }

  // API Đăng nhập (SignIn)
  static Future<String?> signin(String username, String password) async {
    const String apiUrl = "$baseUrl/users/signin";
    final Map<String, String> body = {
      "username": username,
      "password": password,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String accessToken = data['access_token'];
        print(data);
        await _saveAccessToken(accessToken);

        return null; // Thành công
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return errorData['detail']; // Trả về lỗi từ API
      }
    } catch (e) {
      print("Lỗi API signin: $e");
      return "Lỗi kết nối với máy chủ!";
    }
  }

  // API Đăng xuất (SignOut)
  static Future<void> signout() async {
    const String apiUrl = "$baseUrl/users/signout";

    try {
      String? accessToken = await getAccessToken();
      print("🔍 Token hiện tại trước khi đăng xuất: $accessToken");

      if (accessToken == null) {
        print("⚠️ Không tìm thấy accessToken. Vui lòng đăng nhập lại.");
        return;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
      );
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
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes); // Sửa lỗi mã hóa
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
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
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

  static Future<List<Map<String, dynamic>>> searchProduct(String query, {int skip = 0, int limit = 10}) async {
    final String apiUrl = "$baseUrl/products/products?skip=$skip&limit=$limit&search=$query";
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      print("⚠️ Không có accessToken, cần đăng nhập!");
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ).timeout(Duration(seconds: 10));

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
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      print("📥 Dữ liệu API nhận được: $utf8DecodedBody"); // Fix lỗi thiếu dấu `;`
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
}
