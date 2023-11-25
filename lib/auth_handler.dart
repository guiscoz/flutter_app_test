import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './app_config.dart';

class AuthHandler {
  Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('${AppConfig.apiBaseUrl}current_user'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          return true;
        } else {
          prefs.remove('token');
          return false;
        }
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }
}
