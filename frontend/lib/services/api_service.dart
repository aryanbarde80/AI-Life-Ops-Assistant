import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // When running inside Docker Compose, frontend calls backend by service name.
  // For local `flutter run -d chrome`, set to http://localhost:10000
  static const String _baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:10000');

  static Future<String> sendMessage({
    required String userId,
    required String message,
  }) async {
    final uri = Uri.parse('$_baseUrl/chat');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['response'] as String? ?? 'No response from AI.';
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Server error ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
