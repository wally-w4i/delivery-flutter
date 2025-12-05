import 'package:delivery_flutter/models/client.dart';
import 'package:delivery_flutter/src/services/api_service.dart';
import 'package:flutter/material.dart';

class AddClientScreen extends StatefulWidget {
  final Client? client;

  const AddClientScreen({super.key, this.client});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.client?.description ?? '',
    );
    _addressController = TextEditingController(
      text: widget.client?.address ?? '',
    );
    _latitudeController = TextEditingController(
      text: widget.client?.gpsPosition.latitude.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.client?.gpsPosition.longitude.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    if (_formKey.currentState!.validate()) {
      try {
        final client = Client(
          id: widget.client?.id,
          description: _descriptionController.text,
          address: _addressController.text,
          gpsPosition: GpsPosition(
            latitude: double.parse(_latitudeController.text),
            longitude: double.parse(_longitudeController.text),
          ),
        );

        if (widget.client != null) {
          // Update existing client
          await _apiService.updateClient(widget.client!.id!, client);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Client updated successfully!')),
          );
        } else {
          // Create new client
          await _apiService.createClient(client);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Client created successfully!')),
          );
        }
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save client: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.client != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Client' : 'Add New Client')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter latitude';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter longitude';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveClient,
                child: Text(isEditing ? 'Update Client' : 'Add Client'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
