import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/api_error_handler.dart';
import '../utils/auth_handler.dart';
import '../models/user_model.dart';
import '../utils/app_config.dart';
import '../components/navbar.dart';

class HomePage extends StatefulWidget {
  final AuthHandler authHandler;
  
  const HomePage({Key? key, required this.authHandler}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState(authHandler: authHandler);
}

class _HomePageState extends State<HomePage> {
  final AuthHandler authHandler;
  _HomePageState({required this.authHandler});

  List<User> userList = [];
  int currentPage = 1;
  int totalPages = 1;

  Future<void> _fetchUsers(int page) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}list_users?page=$page'),
      );

      if (response.statusCode == 200) {
        setState(() {
          final data = json.decode(response.body);

          if (data['users'].containsKey('data')) {
            userList = List<User>.from(data['users']['data'].map((userData) => User.fromJson(userData)));
            currentPage = data['users']['current_page'];
            totalPages = data['users']['last_page'];
          } else {
            handleApiError(context, 'Não foi possível encontrar dados dos usuários');
          }
        });
      } else {
        handleApiError(context, '${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch(e) {
      handleApiError(context, 'Erro na chamada à API: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        title: 'Home',
        authHandler: authHandler,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: userList.map((userData) => ListTile(title: Text(userData.name))).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: currentPage > 1 ? () => _fetchUsers(currentPage - 1) : null,
                  child: const Text('Página Anterior'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: currentPage < totalPages ? () => _fetchUsers(currentPage + 1) : null,
                  child: const Text('Próxima Página'),
                ),
              ],
            ),
            Text('Página $currentPage de $totalPages'),
          ],
        ),
      ),
    );
  }
}
