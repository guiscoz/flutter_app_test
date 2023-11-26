import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_error_handler.dart';
import '../utils/auth_handler.dart';
import '../components/navbar.dart';
import '../utils/app_config.dart';

class RegisterPage extends StatefulWidget {
  final AuthHandler authHandler;
  const RegisterPage({Key? key, required this.authHandler}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState(authHandler: authHandler);
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthHandler authHandler;
  _RegisterPageState({required this.authHandler});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _token;

  void _performRegister() async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}register'),
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final token = data['token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);

        Navigator.pushNamed(context, '/');
      } else {
        handleApiError(context, 'Erro ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      handleApiError(context, 'Erro na chamada à API: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        title: 'Register', 
        authHandler: authHandler,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _performRegister();
              },
              child: const Text('Register'),
            ),
            if (_token != null) ...[
              const SizedBox(height: 16),
              Text('Token: $_token'),
            ],
          ],
        ),
      ),
    );
  }
}