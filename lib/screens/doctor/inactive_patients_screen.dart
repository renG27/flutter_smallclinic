import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_smallclinic/providers/queue_provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_smallclinic/models/patient.dart';

class InactivePatientsScreen extends StatelessWidget {
  const InactivePatientsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final queueProvider = Provider.of<QueueProvider>(context);

    // Filter for inactive patients
    final inactivePatients = queueProvider.fullQueue.where((patient) => !patient.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inactive Patients'),
         leading: IconButton( // Add back button
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pop(); // Navigate back to previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inactive Patients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: inactivePatients.length,
                itemBuilder: (context, index) {
                  final patient = inactivePatients[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${patient.name}'),
                          Text('Problem: ${patient.problem}'),
                          Text('Enqueued: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(patient.enqueueTime)}'),
                          Text('Status: ${patient.status}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}