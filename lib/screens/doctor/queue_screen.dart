import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_smallclinic/providers/queue_provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_smallclinic/models/patient.dart';
import 'inactive_patients_screen.dart'; // Import the new screen

class DoctorQueueScreen extends StatelessWidget {
  const DoctorQueueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final queueProvider = Provider.of<QueueProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Queue'),
        leading: IconButton( // Add back button
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/'); // Navigate to Welcome screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Patient
            Text(
              queueProvider.currentPatient,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Call Next Patient Button
            ElevatedButton(
              onPressed: () {
                queueProvider.callNextPatient();
              },
              child: const Text('Call Next Patient'),
            ),
            const SizedBox(height: 16),

             ElevatedButton(
              onPressed: () {
                 Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const InactivePatientsScreen()));
              },
              child: const Text('View Inactive Patients'),
            ),
            const SizedBox(height: 16),

            // Queue List
            const Text(
              'Queue:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: queueProvider.activeQueue.length, // Filter the queue here
                itemBuilder: (context, index) {
                  final patient = queueProvider.activeQueue[index]; // Use the filtered queue
                  return Card(
                    color: patient.isActive ? Colors.white : Colors.grey[200], // Indicate inactive patients
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${patient.name}'),
                          Text('Problem: ${patient.problem}'),
                          Text('Enqueued: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(patient.enqueueTime)}'),
                          Text('Status: ${patient.status}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: patient.isActive ? () {
                                  queueProvider.updatePatientStatus(patient, 'In Progress');
                                } : null, // Disable if not active
                                child: const Text('In Progress'),
                              ),
                              ElevatedButton(
                                onPressed: patient.isActive ? () {
                                  queueProvider.updatePatientStatus(patient, 'Done');
                                } : null, // Disable if not active
                                child: const Text('Done'),
                              ),
                              ElevatedButton(
                                onPressed: patient.isActive ? () {
                                  queueProvider.updatePatientStatus(patient, 'Skipped');
                                } : null, // Disable if not active
                                child: const Text('Skip'),
                              ),
                            ],
                          ),
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