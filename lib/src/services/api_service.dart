import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://192.168.20.136:8080';

  Future<String?> authenticate(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/authenticate'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['token'];
    } else {
      return null;
    }
  }
}
