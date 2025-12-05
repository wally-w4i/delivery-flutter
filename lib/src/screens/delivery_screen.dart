import 'package:delivery_flutter/models/delivery.dart';
import 'package:delivery_flutter/src/services/api_service.dart';
import 'package:delivery_flutter/src/screens/add_edit_delivery_screen.dart';
import 'package:flutter/material.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Delivery>> _deliveriesFuture;

  @override
  void initState() {
    super.initState();
    _deliveriesFuture = _apiService.getDeliveries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deliveries')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddEditDeliveryScreen()),
          );
          if (result == true) {
            setState(() {
              _deliveriesFuture = _apiService.getDeliveries();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Delivery>>(
        future: _deliveriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No deliveries found'));
          }

          final deliveries = snapshot.data!;
          return ListView.builder(
            itemCount: deliveries.length,
            itemBuilder: (context, index) {
              final delivery = deliveries[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Text('Delivery #${delivery.id}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) =>
                              AddEditDeliveryScreen(delivery: delivery),
                        ),
                      );
                      if (result == true) {
                        setState(() {
                          _deliveriesFuture = _apiService.getDeliveries();
                        });
                      }
                    },
                  ),
                  subtitle: Text(
                    'Date: ${delivery.date} | Status: ${delivery.status}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Details:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...delivery.details.map((detail) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Text(
                                'Client ID: ${detail.clientId} | Status: ${detail.status ?? "N/A"}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
