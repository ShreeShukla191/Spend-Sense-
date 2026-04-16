import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final token = await _apiService.getToken();
    _isAuthenticated = token != null;
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    
    final error = await _apiService.login(username, password);
    if (error == null) {
      _isAuthenticated = true;
    }
    
    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<void> logout() async {
    await _apiService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<String?> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    final error = await _apiService.register(username, email, password);
    
    _isLoading = false;
    notifyListeners();
    return error;
  }
}
