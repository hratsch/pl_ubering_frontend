// lib/main.dart
import 'package:flutter/material.dart';
import 'package:uber_pl_frontend/services/offline_service.dart';
import 'package:uber_pl_frontend/screens/login_screen.dart';
import 'package:uber_pl_frontend/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OfflineService().init();
  runApp(const UberPLApp());
}

class UberPLApp extends StatelessWidget {
  const UberPLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uber P&L',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}