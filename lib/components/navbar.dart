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
            ],
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
