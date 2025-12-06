import 'dart:convert';
import 'package:delivery_flutter/models/client.dart';
import 'package:delivery_flutter/models/delivery.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  Future<List<Client>> getClients() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/clients'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> clientsJson = jsonDecode(response.body);
      return clientsJson.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load clients');
    }
  }

  Future<Client> createClient(Client client) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/clients'),
      headers: await _getHeaders(),
      body: jsonEncode(client.toJson()),
    );

    if (response.statusCode == 201) {
      return Client.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create client');
    }
  }

  Future<Client> updateClient(int id, Client client) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/clients/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(client.toJson()),
    );

    if (response.statusCode == 200) {
      return Client.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update client');
    }
  }

  Future<List<Delivery>> getDeliveries() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/deliveries'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> deliveriesJson = jsonDecode(response.body);
      return deliveriesJson.map((json) => Delivery.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load deliveries');
    }
  }

  Future<Delivery> createDelivery(Delivery delivery) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/deliveries'),
      headers: await _getHeaders(),
      body: jsonEncode(delivery.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Delivery.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create delivery: ${response.statusCode}');
    }
  }

  Future<Delivery> updateDelivery(int id, Delivery delivery) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/deliveries/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(delivery.toJson()),
    );

    if (response.statusCode == 200) {
      return Delivery.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update delivery: ${response.statusCode}');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        final idToken = await userCredential.user!.getIdToken();
        if (idToken != null) {
          print(idToken);
          await _saveToken(idToken);
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Error Firebase: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error desconocido: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    await _secureStorage.delete(key: 'auth_token');
  }
}
