import 'package:delivery_flutter/models/delivery.dart';
import 'package:delivery_flutter/models/client.dart' as model_client;
import 'package:delivery_flutter/src/services/api_service.dart';
import 'package:flutter/material.dart';

class AddEditDeliveryScreen extends StatefulWidget {
  final Delivery? delivery;
  const AddEditDeliveryScreen({super.key, this.delivery});

  @override
  _AddEditDeliveryScreenState createState() => _AddEditDeliveryScreenState();
}

class _AddEditDeliveryScreenState extends State<AddEditDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  String _status = 'PENDING';
  final ApiService _apiService = ApiService();

  List<model_client.Client> _clients = [];
  final Set<int> _selectedClientIds = {};
  bool _loadingClients = true;

  @override
  void initState() {
    super.initState();
    if (widget.delivery != null) {
      _dateController.text = widget.delivery!.date;
      _status = widget.delivery!.status;
      for (final d in widget.delivery!.details) {
        _selectedClientIds.add(d.clientId);
      }
    }
    _loadClients();
  }

  Future<void> _loadClients() async {
    try {
      final clients = await _apiService.getClients();
      setState(() {
        _clients = clients;
        _loadingClients = false;
      });
    } catch (e) {
      setState(() {
        _loadingClients = false;
      });
      // show simple error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load clients: $e')));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final details = _selectedClientIds
        .map(
          (clientId) =>
              DeliveryDetail(id: null, clientId: clientId, status: null),
        )
        .toList();

    final delivery = Delivery(
      id: widget.delivery?.id,
      date: _dateController.text,
      status: _status,
      details: details,
    );

    try {
      if (widget.delivery == null) {
        await _apiService.createDelivery(delivery);
      } else {
        await _apiService.updateDelivery(widget.delivery!.id!, delivery);
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save delivery: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.delivery == null ? 'Add Delivery' : 'Edit Delivery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter date' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'PENDING', child: Text('PENDING')),
                  DropdownMenuItem(
                    value: 'IN_PROGRESS',
                    child: Text('IN_PROGRESS'),
                  ),
                  DropdownMenuItem(
                    value: 'DELIVERED',
                    child: Text('DELIVERED'),
                  ),
                  DropdownMenuItem(
                    value: 'CANCELLED',
                    child: Text('CANCELLED'),
                  ),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'PENDING'),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Clients to include',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _loadingClients
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _clients.length,
                        itemBuilder: (context, index) {
                          final c = _clients[index];
                          final selected = _selectedClientIds.contains(c.id);
                          return CheckboxListTile(
                            value: selected,
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _selectedClientIds.add(c.id!);
                                } else {
                                  _selectedClientIds.remove(c.id);
                                }
                              });
                            },
                            title: Text(c.description),
                            subtitle: Text(c.address),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
