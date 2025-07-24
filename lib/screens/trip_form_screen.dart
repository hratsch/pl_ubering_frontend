// lib/screens/trip_form_screen.dart
import 'package:flutter/material.dart';
import 'package:uber_pl_frontend/models/trip.dart';
import 'package:uber_pl_frontend/services/api_service.dart';
import 'package:uber_pl_frontend/services/offline_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TripFormScreen extends StatefulWidget {
  final Trip? trip;
  const TripFormScreen({super.key, this.trip});

  @override
  _TripFormScreenState createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  DateTime _date = DateTime.now();
  final _grossEarningsController = TextEditingController();
  final _milesDrivenController = TextEditingController();
  final _hoursWorkedController = TextEditingController();
  final _gasCostController = TextEditingController();
  final _tollsController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      _date = widget.trip!.date;
      _grossEarningsController.text = widget.trip!.grossEarnings.toStringAsFixed(2);
      _milesDrivenController.text = widget.trip!.milesDriven?.toStringAsFixed(2) ?? '';
      _hoursWorkedController.text = widget.trip!.hoursWorked?.toStringAsFixed(2) ?? '';
      _gasCostController.text = widget.trip!.gasCost?.toStringAsFixed(2) ?? '';
      _tollsController.text = widget.trip!.tolls?.toStringAsFixed(2) ?? '';
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
      final tripCreate = TripCreate(
        date: _date,
        grossEarnings: double.parse(_grossEarningsController.text),
        milesDriven: _milesDrivenController.text.isEmpty ? null : double.parse(_milesDrivenController.text),
        hoursWorked: _hoursWorkedController.text.isEmpty ? null : double.parse(_hoursWorkedController.text),
        gasCost: _gasCostController.text.isEmpty ? null : double.parse(_gasCostController.text),
        tolls: _tollsController.text.isEmpty ? null : double.parse(_tollsController.text),
      );

      try {
        final connectivity = await Connectivity().checkConnectivity();
        if (connectivity == ConnectivityResult.none) {
          await OfflineService().saveTripOffline(tripCreate);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saved offline, will sync when online')),
            );
            Navigator.pop(context);
          }
        } else {
          if (widget.trip == null) {
            await _apiService.createTrip(tripCreate);
          } else {
            await _apiService.updateTrip(widget.trip!.id, tripCreate);
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
      appBar: AppBar(title: Text(widget.trip == null ? 'Add Trip' : 'Edit Trip')),
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
              TextFormField(
                controller: _grossEarningsController,
                decoration: const InputDecoration(labelText: 'Gross Earnings'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final num = double.tryParse(value);
                  if (num == null || num <= 0) return 'Must be a positive number';
                  return null;
                },
              ),
              TextFormField(
                controller: _milesDrivenController,
                decoration: const InputDecoration(labelText: 'Miles Driven (optional)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final num = double.tryParse(value);
                  if (num == null || num < 0) return 'Must be a non-negative number';
                  return null;
                },
              ),
              TextFormField(
                controller: _hoursWorkedController,
                decoration: const InputDecoration(labelText: 'Hours Worked (optional)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final num = double.tryParse(value);
                  if (num == null || num < 0) return 'Must be a non-negative number';
                  return null;
                },
              ),
              TextFormField(
                controller: _gasCostController,
                decoration: const InputDecoration(labelText: 'Gas Cost (optional)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final num = double.tryParse(value);
                  if (num == null || num < 0) return 'Must be a non-negative number';
                  return null;
                },
              ),
              TextFormField(
                controller: _tollsController,
                decoration: const InputDecoration(labelText: 'Tolls (optional)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final num = double.tryParse(value);
                  if (num == null || num < 0) return 'Must be a non-negative number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.trip == null ? 'Create Trip' : 'Update Trip'),
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