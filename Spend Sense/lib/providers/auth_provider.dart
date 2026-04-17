import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  bool _isInitializing = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitializing => _isInitializing;

  AuthProvider() {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final token = await _apiService.getToken();
    _isAuthenticated = token != null;
    _isInitializing = false;
    notifyListeners();
  }

  Future<String?> login(String username, String password) async {
    final error = await _apiService.login(username, password);
    if (error == null) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return error;
  }

  Future<void> logout() async {
    await _apiService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<String?> register(String username, String email, String password) async {
    final error = await _apiService.register(username, email, password);
    return error;
  }
}
