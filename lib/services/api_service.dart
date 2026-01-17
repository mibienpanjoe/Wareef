import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Add this
import 'package:mime/mime.dart'; // Add this for lookupMimeType
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // For Flutter Web: Use 127.0.0.1 instead of localhost
  // For Flutter Mobile/Desktop: Use your machine's IP or localhost
  static const String baseServerUrl = 'http://127.0.0.1:3000';
  static const String baseUrl = '$baseServerUrl/api';

  // Helper to get full image URL
  static String? getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    if (imagePath.startsWith('http')) return imagePath;

    final cleanBase = baseServerUrl.endsWith('/')
        ? baseServerUrl.substring(0, baseServerUrl.length - 1)
        : baseServerUrl;
    final cleanPath = imagePath.startsWith('/') ? imagePath : '/$imagePath';

    return '$cleanBase$cleanPath';
  }

  // Helper to join paths safely
  String _buildUrl(String endpoint) {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanEndpoint = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;
    return '$cleanBase/$cleanEndpoint';
  }

  // Get stored token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Make GET request
  Future<http.Response> get(String endpoint) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    // Debug log removed

    // DEBUG: Print headers to verify token format
    // Debug log removed

    try {
      final response = await http.get(
        Uri.parse(_buildUrl(endpoint)),
        headers: headers,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Make POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      // Debug logs removed

      final response = await http.post(
        Uri.parse(_buildUrl(endpoint)),
        headers: headers,
        body: jsonEncode(body),
      );

      // Debug logs removed

      return response;
    } catch (e) {
      // Debug log removed
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Make PUT request
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.put(
        Uri.parse(_buildUrl(endpoint)),
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Make DELETE request
  Future<http.Response> delete(String endpoint) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.delete(
        Uri.parse(_buildUrl(endpoint)),
        headers: headers,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Make Multipart POST request
  Future<http.Response> postMultipart(
    String endpoint,
    Map<String, String> fields, {
    String? filePath,
    String? fileField,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse(_buildUrl(endpoint));
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    request.fields.addAll(fields);

    if (filePath != null && fileField != null) {
      final mimeType = lookupMimeType(filePath);
      final mediaType = mimeType != null
          ? MediaType.parse(mimeType)
          : MediaType('image', 'jpeg');

      request.files.add(
        await http.MultipartFile.fromPath(
          fileField,
          filePath,
          contentType: mediaType,
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Make Multipart PUT request
  Future<http.Response> putMultipart(
    String endpoint,
    Map<String, String> fields, {
    String? filePath,
    String? fileField,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse(_buildUrl(endpoint));
    final request = http.MultipartRequest('PUT', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    request.fields.addAll(fields);

    if (filePath != null && fileField != null) {
      final mimeType = lookupMimeType(filePath);
      final mediaType = mimeType != null
          ? MediaType.parse(mimeType)
          : MediaType('image', 'jpeg');

      request.files.add(
        await http.MultipartFile.fromPath(
          fileField,
          filePath,
          contentType: mediaType,
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // --- Auth Endpoints ---

  Future<dynamic> updateProfile({String? fullname, String? imagePath}) async {
    if (imagePath != null) {
      final fields = <String, String>{};
      if (fullname != null) fields['fullname'] = fullname;

      final response = await putMultipart(
        'auth/me',
        fields,
        filePath: imagePath,
        fileField: 'profileImage',
      );
      return handleResponse(response);
    }

    final body = <String, dynamic>{};
    if (fullname != null) body['fullname'] = fullname;

    final response = await put('auth/me', body);
    return handleResponse(response);
  }

  // --- Category Endpoints ---

  Future<List<dynamic>> getCategories() async {
    final response = await get('categories');
    final data = handleResponse(response);
    return data as List<dynamic>;
  }

  Future<dynamic> addCategory(
    String name,
    String? description, {
    String? imagePath,
  }) async {
    if (imagePath != null) {
      final fields = {
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
      };
      final response = await postMultipart(
        'categories',
        fields,
        filePath: imagePath,
        fileField: 'image',
      );
      return handleResponse(response);
    }
    final body = {
      'name': name,
      if (description != null && description.isNotEmpty)
        'description': description,
    };
    final response = await post('categories', body);
    return handleResponse(response);
  }

  Future<dynamic> updateCategory(
    String id,
    String name,
    String? description, {
    String? imagePath,
  }) async {
    if (imagePath != null) {
      final fields = {
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
      };
      final response = await putMultipart(
        'categories/$id',
        fields,
        filePath: imagePath,
        fileField: 'image',
      );
      return handleResponse(response);
    }
    final body = {
      'name': name,
      if (description != null && description.isNotEmpty)
        'description': description,
    };
    final response = await put('categories/$id', body);
    return handleResponse(response);
  }

  Future<dynamic> deleteCategory(String id) async {
    final response = await delete('categories/$id');
    return handleResponse(response);
  }

  // --- Product Endpoints ---

  Future<List<dynamic>> getProducts() async {
    final response = await get('products');
    final data = handleResponse(response);
    return data as List<dynamic>;
  }

  Future<dynamic> addProduct(
    String name,
    String? categoryId,
    int stockQuantity,
    double price,
    String? description, {
    String? imagePath,
  }) async {
    if (imagePath != null) {
      final fields = {
        'name': name,
        if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
        'stockQuantity': stockQuantity.toString(),
        'price': price.toString(),
        if (description != null && description.isNotEmpty)
          'description': description,
      };
      final response = await postMultipart(
        'products',
        fields,
        filePath: imagePath,
        fileField: 'image',
      );
      return handleResponse(response);
    }

    final body = {
      'name': name,
      if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
      'stockQuantity': stockQuantity,
      'price': price,
      if (description != null && description.isNotEmpty)
        'description': description,
    };
    final response = await post('products', body);
    return handleResponse(response);
  }

  Future<dynamic> updateProduct(
    String id,
    String name,
    String? categoryId,
    int stockQuantity,
    double price,
    String? description, {
    String? imagePath,
  }) async {
    if (imagePath != null) {
      final fields = {
        'name': name,
        if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
        'stockQuantity': stockQuantity.toString(),
        'price': price.toString(),
        if (description != null && description.isNotEmpty)
          'description': description,
      };
      final response = await putMultipart(
        'products/$id',
        fields,
        filePath: imagePath,
        fileField: 'image',
      );
      return handleResponse(response);
    }
    final body = {
      'name': name,
      if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
      'stockQuantity': stockQuantity,
      'price': price,
      if (description != null && description.isNotEmpty)
        'description': description,
    };
    final response = await put('products/$id', body);
    return handleResponse(response);
  }

  Future<dynamic> deleteProduct(String id) async {
    final response = await delete('products/$id');
    return handleResponse(response);
  }

  // --- Stock Movement Endpoints ---

  Future<List<dynamic>> getStockMovements() async {
    final response = await get('stock-movements');
    final data = handleResponse(response);
    return data as List<dynamic>;
  }

  Future<dynamic> addStockMovement(
    String productId,
    String type,
    int quantity,
    String? description,
  ) async {
    final body = {
      'product': productId,
      'type': type,
      'quantity': quantity,
      if (description != null && description.isNotEmpty)
        'description': description,
    };
    final response = await post('stock-movements', body);
    return handleResponse(response);
  }

  Future<dynamic> updateStockMovement(
    String id,
    String productId,
    String type,
    int quantity,
    String? description,
  ) async {
    final body = {
      'product': productId,
      'type': type,
      'quantity': quantity,
      if (description != null && description.isNotEmpty)
        'description': description,
    };
    final response = await put('stock-movements/$id', body);
    return handleResponse(response);
  }

  Future<dynamic> deleteStockMovement(String id) async {
    final response = await delete('stock-movements/$id');
    return handleResponse(response);
  }

  // --- Report Endpoints ---

  Future<List<dynamic>> getStockPerProduct() async {
    final response = await get('reports/stock-per-product');
    final data = handleResponse(response);
    return data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getStockPerCategory() async {
    final response = await get('reports/stock-per-category');
    final data = handleResponse(response);
    return data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getStockMovementsByDate(
    String startDate,
    String endDate,
  ) async {
    final response = await get(
      'reports/movements?startDate=$startDate&endDate=$endDate',
    );
    final data = handleResponse(response);
    return data['movements'] as List<dynamic>;
  }

  Future<List<dynamic>> getLowStockAlert({int threshold = 5}) async {
    final response = await get('reports/low-stock?threshold=$threshold');
    final data = handleResponse(response);
    return data as List<dynamic>;
  }

  // Handle response
  dynamic handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - Please login again');
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'An error occurred');
      } catch (e) {
        throw Exception('Server error: ${response.statusCode}');
      }
    }
  }
}
