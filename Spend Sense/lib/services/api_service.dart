import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/';
    if (defaultTargetPlatform == TargetPlatform.windows) return 'http://localhost:8000/';
    return 'http://10.0.2.2:8000/';
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> setToken(String token, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setString('refresh_token', refresh);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  String _parseError(String body) {
    try {
      if (body.trim().startsWith('<')) {
        return 'Server error or endpoint not found. Please ensure backend is running.';
      }
      final json = jsonDecode(body);
      if (json is Map && json.isNotEmpty) {
        final key = json.keys.first;
        final val = json[key];
        if (val is List && val.isNotEmpty) return '$key: ${val.first}';
        return '$key: $val';
      }
      return body;
    } catch (_) {
      return body;
    }
  }

  // Robust retry mechanism for network timeouts (e.g. Render cold start)
  Future<http.Response> _requestWithRetry(Future<http.Response> Function() requestFunc, {int retries = 2}) async {
    int attempt = 0;
    while (attempt <= retries) {
      try {
        // A generous timeout per attempt, combined with retries, covers > 60s cold starts effortlessly
        return await requestFunc().timeout(const Duration(seconds: 35));
      } on TimeoutException catch (e) {
        attempt++;
        if (attempt > retries) rethrow;
        debugPrint('Request timed out: $e. Retrying ($attempt/$retries)...');
      } catch (e) {
        attempt++;
        if (attempt > retries) rethrow;
        debugPrint('Network error: $e. Retrying ($attempt/$retries)...');
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    throw Exception('Failed after $retries retries');
  }

  Future<String?> login(String username, String password) async {
    try {
      final response = await _requestWithRetry(() => http.post(
        Uri.parse('${baseUrl}auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ));

      debugPrint('Login response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await setToken(data['access'], data['refresh']);
        return null;
      }
      return _parseError(response.body);
    } catch (e) {
      debugPrint('Network or API Error during login: $e');
      return 'Network Error: $e';
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      final response = await _requestWithRetry(() => http.get(Uri.parse('$baseUrl$cleanEndpoint'), headers: headers));
      
      debugPrint('GET $endpoint response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await logout();
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('GET error on $endpoint: $e');
      throw Exception('Network or API Error: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      final response = await _requestWithRetry(() => http.post(
        Uri.parse('$baseUrl$cleanEndpoint'),
        headers: headers,
        body: jsonEncode(body),
      ));

      debugPrint('POST $endpoint response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await logout();
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to post data: ${response.body}');
      }
    } catch (e) {
      debugPrint('POST error on $endpoint: $e');
      throw Exception('Network or API Error: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      final response = await _requestWithRetry(() => http.put(
        Uri.parse('$baseUrl$cleanEndpoint'),
        headers: headers,
        body: jsonEncode(body),
      ));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.body.isEmpty ? null : jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await logout();
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to update data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network or API Error: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      final response = await _requestWithRetry(() => http.delete(
        Uri.parse('$baseUrl$cleanEndpoint'),
        headers: headers,
      ));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      } else if (response.statusCode == 401) {
        await logout();
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to delete data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network or API Error: $e');
    }
  }

  Future<String?> register(String username, String email, String password) async {
    try {
      final response = await _requestWithRetry(() => http.post(
        Uri.parse('${baseUrl}auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': password,
        }),
      ));

      debugPrint('Register response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        return null;
      }
      return _parseError(response.body);
    } catch (e) {
      debugPrint('Network or API Error during register: $e');
      return 'Network Error: $e';
    }
  }
}
