import 'package:delivery_flutter/models/client.dart';
import 'package:delivery_flutter/src/services/api_service.dart';

class ClientService {
  final ApiService _apiService = ApiService();

  Future<List<Client>> getClients() async {
    return await _apiService.getClients();
  }

  Future<Client> createClient(Client client) async {
    return await _apiService.createClient(client);
  }

  Future<Client> updateClient(int id, Client client) async {
    return await _apiService.updateClient(id, client);
  }
}
