import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHelper {
  static const String baseUrl = "https://appoiment.cloudregex.com/api";
  static String? authToken; // set this after login

  /// Universal request function
  static Future<dynamic> request(
    String endpoint, {
    String method = "GET",
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse("$baseUrl/$endpoint");

    // Default headers
    final defaultHeaders = {
      "Content-Type": "application/json",
      if (authToken != null) "Authorization": "Bearer $authToken",
    };

    // Merge custom headers if any
    final mergedHeaders = {...defaultHeaders, ...?headers};

    http.Response response;

    switch (method.toUpperCase()) {
      case "POST":
        response = await http.post(
          url,
          headers: mergedHeaders,
          body: jsonEncode(body),
        );
        break;
      case "PUT":
        response = await http.put(
          url,
          headers: mergedHeaders,
          body: jsonEncode(body),
        );
        break;
      case "DELETE":
        response = await http.delete(
          url,
          headers: mergedHeaders,
          body: jsonEncode(body),
        );
        break;
      default: // GET
        response = await http.get(url, headers: mergedHeaders);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception("API Error: ${response.statusCode} - ${response.body}");
    }
  }
}
