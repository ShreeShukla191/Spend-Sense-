import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String _currentBaseUrl = _getDefaultBaseUrl();

  static String _getDefaultBaseUrl() {
    return 'https://spend-sense-z2cy.onrender.com/';
  }

  static String get baseUrl => _currentBaseUrl;

  static void setBaseUrl(String url) {
    if (!url.endsWith('/')) url += '/';
    _currentBaseUrl = url;
  }

  static void switchBaseUrl() {
    if (_currentBaseUrl.contains('localhost')) {
      _currentBaseUrl = _currentBaseUrl.replaceAll('localhost', '127.0.0.1');
    } else if (_currentBaseUrl.contains('127.0.0.1')) {
      _currentBaseUrl = _currentBaseUrl.replaceAll('127.0.0.1', 'localhost');
    }
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

  // Robust retry mechanism for network timeouts and local host resolution issues
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
        String errorStr = e.toString().toLowerCase();
        // If we hit a connection error on web or desktop, it might be a localhost vs 127.0.0.1 issue (IPv4/IPv6 mismatch)
        if (errorStr.contains('failed to fetch') || errorStr.contains('connection refused') || errorStr.contains('socketexception')) {
          debugPrint('Connection error detected. Switching base URL and retrying...');
          switchBaseUrl();
        }
        
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
      if (e.toString().contains('Failed to fetch')) {
        return 'Network Error: Cannot connect to server. Please ensure the backend is running at ${baseUrl}.';
      }
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
      if (e.toString().contains('Failed to fetch')) {
        return 'Network Error: Cannot connect to server. Please ensure the backend is running at ${baseUrl}.';
      }
      return 'Network Error: $e';
    }
  }
}
