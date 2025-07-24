// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uber_pl_frontend/models/trip.dart';
import 'package:uber_pl_frontend/models/expense.dart';

class ApiService {
  static const String baseUrl = 'https://qcosyycifpemilbatncwgqgk.rtunl.app';
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

  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No token found');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Trips CRUD
  Future<Trip> createTrip(TripCreate trip) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/trips'),
      headers: await _getHeaders(),
      body: jsonEncode(trip.toJson()),
    );
    if (response.statusCode == 200) {
      return Trip.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body)['error'];
      throw Exception(error ?? 'Failed to create trip');
    }
  }

  Future<List<Trip>> getTrips({int skip = 0, int limit = 100}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/trips?skip=$skip&limit=$limit'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Trip.fromJson(json)).toList();
    } else {
      final error = jsonDecode(response.body)['error'];
      throw Exception(error ?? 'Failed to fetch trips');
    }
  }

  Future<Trip> updateTrip(int id, TripCreate trip) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/trips/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(trip.toJson()),
    );
    if (response.statusCode == 200) {
      return Trip.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body)['error'];
      throw Exception(error ?? 'Failed to update trip');
    }
  }

  Future<void> deleteTrip(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/trips/$id'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['error'];
      throw Exception(error ?? 'Failed to delete trip');
    }
  }

  // Expenses CRUD
  Future<Expense> createExpense(ExpenseCreate expense) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/expenses'),
      headers: await _getHeaders(),
      body: jsonEncode(expense.toJson()),
    );
    if (response.statusCode == 200) {
      return Expense.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body)['error'];
      throw Exception(error ?? 'Failed to create expense');
    }
  }

  Future<List<Expense>> getExpenses({int skip = 0, int limit = 100}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/expenses?skip=$skip&limit=$limit'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Expense.fromJson(json)).toList();
    } else {
      final error = jsonDecode(response.body)['error'];
      throw Exception(error ?? 'Failed to fetch expenses');
    }
  }

  Future<Expense> updateExpense(int id, ExpenseCreate expense) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/expenses/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(expense.toJson()),
    );
    if (response.statusCode == 200) {
      return Expense.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body)['error'];
      throw Exception(error ?? 'Failed to update expense');
    }
  }

  Future<void> deleteExpense(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/expenses/$id'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['error'];
      throw Exception(error ?? 'Failed to delete expense');
    }
  }
}