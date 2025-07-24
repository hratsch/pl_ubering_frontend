// lib/services/offline_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uber_pl_frontend/models/trip.dart';
import 'package:uber_pl_frontend/models/expense.dart';
import 'package:uber_pl_frontend/services/api_service.dart';

class OfflineService {
  static const String tripBoxName = 'trips';
  static const String expenseBoxName = 'expenses';
  final ApiService _apiService = ApiService();

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TripCreateAdapter());
    Hive.registerAdapter(ExpenseCreateAdapter());
    await Hive.openBox<TripCreate>(tripBoxName);
    await Hive.openBox<ExpenseCreate>(expenseBoxName);
  }

  Future<void> saveTripOffline(TripCreate trip) async {
    final box = Hive.box<TripCreate>(tripBoxName);
    await box.add(trip);
  }

  Future<void> saveExpenseOffline(ExpenseCreate expense) async {
    final box = Hive.box<ExpenseCreate>(expenseBoxName);
    await box.add(expense);
  }

  Future<void> syncWithBackend() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    final tripBox = Hive.box<TripCreate>(tripBoxName);
    final expenseBox = Hive.box<ExpenseCreate>(expenseBoxName);

    for (var trip in tripBox.values.toList()) {
      try {
        await _apiService.createTrip(trip);
        await tripBox.delete(trip.key); // Use key to delete specific entry
      } catch (e) {
        // Log error, keep for next sync (e.g., print('Sync error: $e'))
      }
    }

    for (var expense in expenseBox.values.toList()) {
      try {
        await _apiService.createExpense(expense);
        await expenseBox.delete(expense.key); // Use key to delete specific entry
      } catch (e) {
        // Log error, keep for next sync (e.g., print('Sync error: $e'))
      }
    }
  }
}