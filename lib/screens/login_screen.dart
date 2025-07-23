// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uber_pl_frontend/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState(); // Private state class
}

class _LoginScreenState extends State<LoginScreen> {
  final _localAuth = LocalAuthentication();
  final _apiService = ApiService();
  final _passwordController = TextEditingController();
  bool _isBiometricAvailable = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _localAuth.canCheckBiometrics;
    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable;
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Uber P&L',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuthenticate && mounted) {
        final password = await ApiService().storage.read(key: 'password') ?? 'test';
        await _login(password);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Biometric authentication failed';
        });
      }
    }
  }

  Future<void> _login(String password) async {
    try {
      await _apiService.login(password);
      await ApiService().storage.write(key: 'password', value: password);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          String message;
          if (e.toString().contains('401')) {
            message = 'Invalid credentials, please try again';
          } else if (e.toString().contains('400')) {
            message = 'Invalid request, please check your input';
          } else {
            message = 'An error occurred, please try again later';
          }
          _errorMessage = message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isBiometricAvailable)
              ElevatedButton(
                onPressed: _authenticateWithBiometrics,
                child: const Text('Login with Biometrics'),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _login(_passwordController.text),
              child: const Text('Login with Password'),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}