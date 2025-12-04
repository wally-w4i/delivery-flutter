import 'package:delivery_flutter/src/services/client_service.dart';
import 'package:flutter/material.dart';

import 'package:delivery_flutter/models/client.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  _ClientListScreenState createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final ClientService _clientService = ClientService();
  List<Client> _clients = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final clients = await _clientService.getClients();
    setState(() {
      _clients = clients;
    });
  }

  Future<void> _addClient() async {
    final result = await showDialog<Client>(
      context: context,
      builder: (context) => const AddClientDialog(),
    );
    if (result != null) {
      setState(() {
        _clients.add(result);
      });
      await _clientService.saveClients(_clients);
    }
  }

  Future<void> _editClient(int index) async {
    final result = await showDialog<Client>(
      context: context,
      builder: (context) => EditClientDialog(client: _clients[index]),
    );
    if (result != null) {
      setState(() {
        _clients[index] = result;
      });
      await _clientService.saveClients(_clients);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [IconButton(icon: const Icon(Icons.map), onPressed: () {})],
      ),
      body: ListView.builder(
        itemCount: _clients.length,
        itemBuilder: (context, index) {
          final client = _clients[index];
          return ListTile(
            title: Text(client.description),
            subtitle: Text(
              '${client.address}\nLat: ${client.lat ?? 'N/A'}, Lng: ${client.lng ?? 'N/A'}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editClient(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClient,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditClientDialog extends StatefulWidget {
  final Client client;

  const EditClientDialog({super.key, required this.client});

  @override
  _EditClientDialogState createState() => _EditClientDialogState();
}

class _EditClientDialogState extends State<EditClientDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _description;
  late String _address;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _description = widget.client.description;
    _address = widget.client.address;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Client'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              onSaved: (value) => _description = value!,
            ),
            TextFormField(
              initialValue: _address,
              decoration: const InputDecoration(labelText: 'Address'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an address';
                }
                return null;
              },
              onSaved: (value) => _address = value!,
            ),
            const SizedBox(height: 10),
            Text(
              _selectedLocation == null
                  ? 'No location selected'
                  : 'Lat: ${_selectedLocation!.latitude}, Lng: ${_selectedLocation!.longitude}',
            ),
            ElevatedButton(
              child: const Text('Select Location'),
              onPressed: () async {},
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.of(context).pop(
                Client(
                  description: _description,
                  address: _address,
                  lat: _selectedLocation?.latitude,
                  lng: _selectedLocation?.longitude,
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class AddClientDialog extends StatefulWidget {
  const AddClientDialog({super.key});

  @override
  _AddClientDialogState createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<AddClientDialog> {
  final _formKey = GlobalKey<FormState>();
  String _description = '';
  String _address = '';
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Client'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              onSaved: (value) => _description = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Address'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an address';
                }
                return null;
              },
              onSaved: (value) => _address = value!,
            ),
            const SizedBox(height: 10),
            Text(
              _selectedLocation == null
                  ? 'No location selected'
                  : 'Lat: ${_selectedLocation!.latitude}, Lng: ${_selectedLocation!.longitude}',
            ),
            ElevatedButton(
              child: const Text('Select Location'),
              onPressed: () async {},
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.of(context).pop(
                Client(
                  description: _description,
                  address: _address,
                  lat: _selectedLocation?.latitude,
                  lng: _selectedLocation?.longitude,
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
