// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:uber_pl_frontend/models/trip.dart';
import 'package:uber_pl_frontend/models/expense.dart';
import 'package:uber_pl_frontend/services/api_service.dart';
import 'package:uber_pl_frontend/screens/trip_form_screen.dart';
import 'package:uber_pl_frontend/screens/expense_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _apiService = ApiService();
  List<Trip> _trips = [];
  List<Expense> _expenses = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final trips = await _apiService.getTrips();
      final expenses = await _apiService.getExpenses();
      if (mounted) {
        setState(() {
          _trips = trips;
          _expenses = expenses;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const TripFormScreen()));
                    _loadData();
                  },
                  child: const Text('Add Trip'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseFormScreen()));
                    _loadData();
                  },
                  child: const Text('Add Expense'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Trips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ..._trips.map((trip) => ListTile(
                      title: Text('Date: ${trip.date.toIso8601String().split('T')[0]}'),
                      subtitle: Text('Earnings: \$${trip.grossEarnings.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => TripFormScreen(trip: trip)));
                              _loadData();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await _apiService.deleteTrip(trip.id);
                              _loadData();
                            },
                          ),
                        ],
                      ),
                    )),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ..._expenses.map((expense) => ListTile(
                      title: Text('Date: ${expense.date.toIso8601String().split('T')[0]}'),
                      subtitle: Text('Category: ${expense.category[0].toUpperCase() + expense.category.substring(1)}, Amount: \$${expense.amount.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseFormScreen(expense: expense)));
                              _loadData();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await _apiService.deleteExpense(expense.id);
                              _loadData();
                            },
                          ),
                        ],
                      ),
                    )),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}