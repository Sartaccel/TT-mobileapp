
import 'package:shared_preferences/shared_preferences.dart';

class UserCredentials {
  String username;
  String password;

  UserCredentials({required this.username, required this.password});


  Future<void> saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }


  static Future<UserCredentials?> loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    if (username != null && password != null) {
      return UserCredentials(username: username, password: password);
    }
    return null;
  }

  Future<void> deleteCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
  }

  @override
  String toString() {
    return 'UserCredentials(username: $username, password: $password)';
  }
}
