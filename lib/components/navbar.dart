import 'package:flutter/material.dart';
import '../auth_handler.dart'; 

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({
    Key? key,
    required this.title,
    required this.authHandler,
  }) : super(key: key);

  final String title;
  final AuthHandler authHandler;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<bool> isAuthenticated() async {
    return await authHandler.isAuthenticated();
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      await authHandler.logout();
      Navigator.pushNamed(context, '/');
    } catch (e) {
      final errorMessage = 'Erro durante o logout: $e';
      print(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final authenticated = snapshot.data ?? false;

          return AppBar(
            title: Text(title),
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
              ),
              if (!authenticated)
                IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              if (!authenticated)
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),
              if (authenticated)
                IconButton(
                  icon: const Icon(Icons.account_circle_outlined),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              if (authenticated)
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await _performLogout(context);
                  },
                ),
            ],
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
