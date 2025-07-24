// lib/screens/expense_form_screen.dart
import 'package:flutter/material.dart';
import 'package:uber_pl_frontend/models/expense.dart';
import 'package:uber_pl_frontend/services/api_service.dart';
import 'package:uber_pl_frontend/services/offline_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;
  const ExpenseFormScreen({super.key, this.expense});

  @override
  _ExpenseFormScreenState createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  DateTime _date = DateTime.now();
  String _category = 'maintenance';
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _errorMessage;

  static const List<String> categories = ['maintenance', 'insurance', 'phone', 'other'];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _date = widget.expense!.date;
      _category = widget.expense!.category;
      _amountController.text = widget.expense!.amount.toStringAsFixed(2);
      _descriptionController.text = widget.expense!.description ?? '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final expenseCreate = ExpenseCreate(
        date: _date,
        category: _category,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );

      try {
        final connectivity = await Connectivity().checkConnectivity();
        if (connectivity == ConnectivityResult.none) {
          await OfflineService().saveExpenseOffline(expenseCreate);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saved offline, will sync when online')),
            );
            Navigator.pop(context);
          }
        } else {
          if (widget.expense == null) {
            await _apiService.createExpense(expenseCreate);
          } else {
            await _apiService.updateExpense(widget.expense!.id, expenseCreate);
          }
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = e.toString().replaceFirst('Exception: ', '');
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text('Date: ${_date.toIso8601String().split('T')[0]}'),
              ),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c[0].toUpperCase() + c.substring(1)))).toList(),
                onChanged: (value) => setState(() => _category = value!),
                validator: (value) => value == null ? 'Required' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final num = double.tryParse(value);
                  if (num == null || num <= 0) return 'Must be a positive number';
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.expense == null ? 'Create Expense' : 'Update Expense'),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}