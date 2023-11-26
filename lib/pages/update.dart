import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../auth_handler.dart';
import '../components/navbar.dart';
import '../app_config.dart';

class UpdatePage extends StatefulWidget {
  final AuthHandler authHandler;
  const UpdatePage({Key? key, required this.authHandler}) : super(key: key);

  @override
  _UpdatePageState createState() => _UpdatePageState(authHandler: authHandler);
}

class _UpdatePageState extends State<UpdatePage> {
  final AuthHandler authHandler;
  _UpdatePageState({required this.authHandler});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<bool> isAuthenticated() async {
    return await authHandler.isAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: authHandler.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Aguarde até que a verificação de autenticação seja concluída
          return CircularProgressIndicator();
        } else if (!snapshot.data!) {
          // Usuário não autenticado, redirecione para a página de login
          Navigator.pushNamed(context, '/login');
          return Container(); // ou pode retornar um widget indicando que está redirecionando
        } else {
          // Usuário autenticado, retorne o Scaffold normalmente
          return Scaffold(
            appBar: Navbar(
              title: 'Update',
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
                      _performUpdate();
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            ),
          );
        }
      }
    );
  }

  void _performUpdate() async {
  final String name = _nameController.text;
  final String email = _emailController.text;
  final String password = _passwordController.text;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  try {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}current_user/update_data?_method=PUT'),
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 201) {
        Navigator.pushNamed(context, '/profile');
      } else {
        final errorMessage = 'Erro na chamada à API: ${response.statusCode}';
        print(errorMessage);
      }
    } catch (e) {
      final errorMessage = 'Erro na chamada à API: $e';
      print(errorMessage);
    }
  }
}