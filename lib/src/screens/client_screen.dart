import 'package:delivery_flutter/models/client.dart';
import 'package:delivery_flutter/src/screens/add_client_screen.dart';
import 'package:delivery_flutter/src/screens/login_screen.dart';
import 'package:delivery_flutter/src/services/api_service.dart';
import 'package:flutter/material.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Client>> _clients;

  @override
  void initState() {
    super.initState();
    _refreshClients();
  }

  void _refreshClients() {
    setState(() {
      _clients = _apiService.getClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _apiService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Client>>(
        future: _clients,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final client = snapshot.data![index];
                return ListTile(
                  title: Text(client.description),
                  subtitle: Text(client.address),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClientScreen()),
          );
          _refreshClients();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}