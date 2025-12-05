import 'dart:convert';
import 'package:delivery_flutter/models/client.dart';
import 'package:delivery_flutter/models/delivery.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://192.168.20.136:8080';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

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
      final token = jsonDecode(response.body)['token'];
      await _saveToken(token);
      return token;
    } else {
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  Future<List<Client>> getClients() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/clients'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> clientsJson = jsonDecode(response.body);
      return clientsJson.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load clients');
    }
  }

  Future<Client> createClient(Client client) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/clients'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(client.toJson()),
    );

    if (response.statusCode == 201) {
      return Client.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create client');
    }
  }

  Future<Client> updateClient(int id, Client client) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/api/clients/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(client.toJson()),
    );

    if (response.statusCode == 200) {
      return Client.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update client');
    }
  }

  Future<List<Delivery>> getDeliveries() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/deliveries'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> deliveriesJson = jsonDecode(response.body);
      return deliveriesJson.map((json) => Delivery.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load deliveries');
    }
  }
}
