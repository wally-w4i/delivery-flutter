import 'dart:convert';
import 'dart:io';

import 'package:delivery_flutter/models/client.dart';
import 'package:path_provider/path_provider.dart';

class ClientService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/clients.json');
  }

  Future<List<Client>> getClients() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as List;
      return json.map((client) => Client.fromJson(client)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveClients(List<Client> clients) async {
    final file = await _localFile;
    final json = clients.map((client) => client.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }
}
