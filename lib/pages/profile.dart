import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/auth_handler.dart';
import '../models/user_model.dart';
import '../utils/app_config.dart';
import '../components/navbar.dart';
import '../utils/api_error_handler.dart';

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
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}current_user'),
        headers: {'Authorization': 'Bearer ${await authHandler.getToken()}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          final data = json.decode(response.body);
          if (data['user'] != null) {
            currentUser = User.fromJson(data['user']);
          }
        });
      } else {
        handleApiError(context, 'Erro ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch(e) {
      handleApiError(context, 'Erro na chamada à API: $e');
    }
  }

  Future<void> _removeAccount() async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}current_user/remove_account'),
        headers: {'Authorization': 'Bearer ${await authHandler.getToken()}'},
      );

      if (response.statusCode == 200) {
        Navigator.pushNamed(context, '/');
      } else {
        handleApiError(context, 'Erro ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      handleApiError(context, 'Erro na chamada à API: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: authHandler.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Aguarde até que a verificação de autenticação seja concluída
          return const CircularProgressIndicator();
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
                  if (currentUser != null)
                    Text('Name: ${currentUser!.name}'),
                  if (currentUser != null)
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
