import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../components/navbar.dart';
import '../utils/app_config.dart';
import '../utils/auth_handler.dart';
import '../utils/api_error_handler.dart';

class LoginPage extends StatefulWidget {
  final AuthHandler authHandler;
  const LoginPage({Key? key, required this.authHandler}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState(authHandler: authHandler);
}

class _LoginPageState extends State<LoginPage> {
  final AuthHandler authHandler;
  _LoginPageState({required this.authHandler});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _performLogin() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}login'),
        body: {
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
        title: 'Login',
        authHandler: authHandler,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                _performLogin();
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}