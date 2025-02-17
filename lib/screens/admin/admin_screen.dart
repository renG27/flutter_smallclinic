import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_smallclinic/providers/queue_provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_smallclinic/models/patient.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _nameController = TextEditingController();
  final _problemController = TextEditingController();
  final _vaccinationTypeController = TextEditingController(); // Added controller
  DateTime? _vaccinationDate; // Added date

  @override
  void dispose() {
    _nameController.dispose();
    _problemController.dispose();
    _vaccinationTypeController.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queueProvider = Provider.of<QueueProvider>(context);

    // Calculate Admin Panel Information
    final totalActivePatients = queueProvider.activeQueue.length;
    final totalPatientsToday = queueProvider.fullQueue.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();// Back to Welcome screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Options',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Display Admin Information
            Text('Total Active Patients: $totalActivePatients'),
            Text('Total Patients Today: $totalPatientsToday'),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showAddPatientDialog(context, queueProvider);
              },
              child: const Text('Add New Patient'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _showAllPatientsDialog(context, queueProvider);
              },
              child: const Text('View All Patients'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddPatientDialog(BuildContext context, QueueProvider queueProvider) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Patient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Patient Name'),
              ),
              TextField(
                controller: _problemController,
                decoration: const InputDecoration(labelText: 'Patient Problem'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty && _problemController.text.isNotEmpty) {
                  queueProvider.addPatientToQueue(
                    name: _nameController.text,
                    problem: _problemController.text,
                  );
                  _nameController.clear();
                  _problemController.clear();
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAllPatientsDialog(BuildContext context, QueueProvider queueProvider) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('All Patients'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: queueProvider.fullQueue.length,
              itemBuilder: (context, index) {
                final patient = queueProvider.fullQueue[index];
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showEditPatientDialog(context, queueProvider, patient);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: patient.isActive ? () { // Check if active
                                _deletePatient(context, queueProvider, patient);
                              } : null, // Disable if not active
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

    Future<void> _deletePatient(BuildContext context, QueueProvider queueProvider, Patient patient) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${patient.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel the delete
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                queueProvider.updatePatientStatus(patient, 'Deleted');
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the All Patients dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

    Future<void> _showEditPatientDialog(BuildContext context, QueueProvider queueProvider, Patient patient) async {
    _nameController.text = patient.name;
    _problemController.text = patient.problem;
    _vaccinationTypeController.text = patient.vaccinationType ?? '';
    _vaccinationDate = patient.vaccinationDate;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Patient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Patient Name'),
                ),
                TextField(
                  controller: _problemController,
                  decoration: const InputDecoration(labelText: 'Patient Problem'),
                ),
                TextField(
                  controller: _vaccinationTypeController,
                  decoration: const InputDecoration(labelText: 'Vaccination Type (optional)'),
                ),
                 Row(
                  children: [
                    Text(_vaccinationDate == null
                        ? 'No vaccination date chosen'
                        : 'Vaccination date: ${DateFormat('yyyy-MM-dd').format(_vaccinationDate!)}'),
                    TextButton(
                      onPressed: () async {
                         final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null && picked != _vaccinationDate) {
                           setState(() {
                              _vaccinationDate = picked;
                           });
                        }
                      },
                      child: const Text('Select date'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {

                  //Update Data

                   await queueProvider.dbHelper.updatePatient(
                    id: patient.id,
                    name: _nameController.text,
                    problem: _problemController.text,
                    vaccinationType: _vaccinationTypeController.text.isNotEmpty
                        ? _vaccinationTypeController.text
                        : null,
                    vaccinationDate: _vaccinationDate,
                  );
                  await queueProvider.loadQueue();
                  // Force rebuild
                  setState(() {});
                
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}