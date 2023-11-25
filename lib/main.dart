import 'package:flutter/material.dart';
import 'auth_handler.dart';
import './pages/home.dart';
import './pages/login.dart';

void main() {
  final AuthHandler authHandler = AuthHandler();
  runApp(MyApp(authHandler: authHandler));
}

class MyApp extends StatelessWidget {
  final AuthHandler authHandler;

  const MyApp({Key? key, required this.authHandler}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => HomePage(authHandler: authHandler),
        '/login': (context) => LoginPage(authHandler: authHandler),
        '/register': (context) => LoginPage(authHandler: authHandler),
      },
    );
  }
}