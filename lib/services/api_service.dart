// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://uberpl.yourdomain.com'; // Replace with your Cloudflare Tunnel URL
  final storage = const FlutterSecureStorage();

  Future<String?> login(String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      await storage.write(key: 'jwt_token', value: token);
      return token;
    } else {
      final error = jsonDecode(response.body)['error'];
      throw Exception(error ?? 'Login failed');
    }
  }

  Future<String?> refreshToken() async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/refresh'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newToken = data['access_token'];
      await storage.write(key: 'jwt_token', value: newToken);
      return newToken;
    } else {
      await storage.delete(key: 'jwt_token');
      throw Exception('Token refresh failed');
    }
  }
}