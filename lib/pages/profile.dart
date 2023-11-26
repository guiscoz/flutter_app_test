import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../auth_handler.dart';
import '../models/user_model.dart';
import '../app_config.dart';
import '../components/navbar.dart';

class ProfilePage extends StatefulWidget {
  final AuthHandler authHandler;
  
  const ProfilePage({Key? key, required this.authHandler}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState(authHandler: authHandler);
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthHandler authHandler;
  _ProfilePageState({required this.authHandler});

  User? currentUser;
  Future<bool> isAuthenticated() async {
    return await authHandler.isAuthenticated();
  }

  Future<void> _fetchUserProfile() async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}current_user'),
      headers: {'Authorization': 'Bearer ${await authHandler.getToken()}'},
    );

    if (response.statusCode == 200) {
      setState(() {
        final data = json.decode(response.body);
        final dataUser = data['user'];
        final name = dataUser.name; 
        if (data['user'] != null) {
          currentUser = User.fromJson(data['user']);
        }
      });
    } else {
      print('Erro na requisição à API: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _removeAccount() async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}current_user/remove_account'),
        headers: {'Authorization': 'Bearer ${await authHandler.getToken()}'},
      );

      if (response.statusCode == 204) {
        Navigator.pushNamed(context, '/');
      } else {
        final errorMessage = 'Erro ao remover a conta: ${response.statusCode}';
        print(errorMessage);
      }
    } catch (e) {
      final errorMessage = 'Erro ao remover a conta: $e';
      print(errorMessage);
    }
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
          return Scaffold(
            appBar: Navbar(
              title: 'Profile',
              authHandler: authHandler,
            ),
            body: Center(
              child: Column(
                children: [
                  Text('Name: ${currentUser!.name}'),
                  Text('Email: ${currentUser!.email}'),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pushNamed(context, '/update');
                    },
                  ),
                  IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _removeAccount();
                  },
                ),
                ],
              ),
            ),
          );
        }
      }
    );
  }
}
