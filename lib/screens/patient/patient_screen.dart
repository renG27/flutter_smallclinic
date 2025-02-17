import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_smallclinic/providers/queue_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_smallclinic/models/patient.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({Key? key}) : super(key: key);

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final _nameController = TextEditingController();
  final _problemController = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _configureDidReceiveLocalNotificationSubject();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  void _configureDidReceiveLocalNotificationSubject() {
    flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification tap
        print('Notification tapped with ID: ${details.id}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final queueProvider = Provider.of<QueueProvider>(context);
    // Calculate Queue Number and Estimated Wait Time
    int patientQueueNumber = -1; // Default value if not in queue
    int estimatedWaitTime = 0;

    // Find the Patient's index (queue number) in activeQueue
    if (_nameController.text.isNotEmpty) {
      int index = queueProvider.activeQueue.indexWhere((patient) => patient.name == _nameController.text && patient.problem == _problemController.text);

      if (index != -1) {
        patientQueueNumber = index + 1; // Queue numbers start from 1
        estimatedWaitTime = index * 10; // Assuming 10 minutes per patient
      }
    }

    int totalQueueLength = queueProvider.fullQueue.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Screen'),
        leading: IconButton(
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
            // Add to Queue Section
            const Text(
              'Add Yourself to the Queue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Your Name'),
            ),
            TextField(
              controller: _problemController,
              decoration: const InputDecoration(labelText: 'Your Problem'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty && _problemController.text.isNotEmpty) {
                  queueProvider.addPatientToQueue(
                    name: _nameController.text,
                    problem: _problemController.text,
                  );
                  FocusScope.of(context).unfocus();

                  // Force rebuild
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter your name and problem.')),
                  );
                }
              },
              child: const Text('Add to Queue'),
            ),
            const SizedBox(height: 32),

            // Queue Information Section
            const Text(
              'Queue Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text('Current Patient: ${queueProvider.currentPatient}'),
            Text('Your Queue Number: ${totalQueueLength}'),
           // Text('Your Queue Number: ${patientQueueNumber == -1 ? "Not in Queue" : patientQueueNumber}'), // just for estimate waiting time not showing in screen
            Text('Estimated Wait Time: ${patientQueueNumber == -1 ? "Not in Queue" : "$estimatedWaitTime minutes"}'),
          ],
        ),
      ),
    );
  }
}