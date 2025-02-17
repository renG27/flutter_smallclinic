import 'package:flutter/foundation.dart';
import 'package:flutter_smallclinic/models/patient.dart';
import 'package:flutter_smallclinic/services/database_helper.dart';
import 'package:flutter_smallclinic/services/notification_service.dart';

class QueueProvider extends ChangeNotifier {
  final DatabaseHelper dbHelper;
  final LocalNotificationService localNotificationService;

  List<Patient> _fullQueue = []; // The full queue of all patients
  List<Patient> _activeQueue = []; // The queue of active patients only
  String _nextPatient = 'No patient in Queue';
  String _currentPatient = 'No patient in Queue'; // Track current patient

  QueueProvider({required this.dbHelper, required this.localNotificationService}) {
    loadQueue();
  }

  List<Patient> get fullQueue => _fullQueue; // Expose the full queue
  List<Patient> get activeQueue => _activeQueue; // Expose the active queue
  String get nextPatient => _nextPatient;
  String get currentPatient => _currentPatient;

  Future<void> loadQueue() async {
    final patientsFromDb = await dbHelper.getPatients();
    _fullQueue = patientsFromDb.map((patient) => Patient.fromMap(patient)).toList();
    _fullQueue.sort((a, b) => a.enqueueTime.compareTo(b.enqueueTime)); // Sort full queue
    _activeQueue = _fullQueue.where((patient) => patient.isActive).toList(); // Create active queue
    _activeQueue.sort((a, b) => a.enqueueTime.compareTo(b.enqueueTime)); // Sort active queue
    _updateNextPatient();
    _updateCurrentPatient();
    notifyListeners();
  }

  Future<void> addPatientToQueue({
    required String name,
    required String problem,
    String? vaccinationType,
    DateTime? vaccinationDate,
  }) async {
    final id = await dbHelper.insertPatient(
      name: name,
      problem: problem,
      vaccinationType: vaccinationType,
      vaccinationDate: vaccinationDate,
    );
    final now = DateTime.now();
    final newPatient = Patient(
      id: id,
      name: name,
      problem: problem,
      enqueueTime: now,
      vaccinationType: vaccinationType,
      vaccinationDate: vaccinationDate,
    );
    _fullQueue.add(newPatient);
    _fullQueue.sort((a, b) => a.enqueueTime.compareTo(b.enqueueTime)); // Sort full queue
    _activeQueue = _fullQueue.where((patient) => patient.isActive).toList(); // Create active queue
    _activeQueue.sort((a, b) => a.enqueueTime.compareTo(b.enqueueTime)); // Sort active queue
    _updateNextPatient();
    notifyListeners();
  }

  Future<void> callNextPatient() async {
    if (_activeQueue.isNotEmpty) {
      Patient next = _activeQueue.first;
      next.status = 'In Progress'; // Update status to "In Progress"
      await dbHelper.updatePatientStatus(next.id, 'In Progress');
      _updateNextPatient();
      _updateCurrentPatient();
      notifyListeners();
      localNotificationService.showNotification(
        id: next.id,
        title: 'Calling Patient',
        body: 'Please attend to: ${next.name}',
      );
    } else {
      _nextPatient = 'No patient in Queue';
      notifyListeners();
    }
  }

 Future<void> updatePatientStatus(Patient patient, String status) async {
    patient.status = status;
    await dbHelper.updatePatientStatus(patient.id, status);

    if (status == 'Done' || status == 'Skipped' || status == 'Deleted') {
      patient.isActive = false;
      await dbHelper.updatePatientIsActive(patient.id, false);
    } else {
      patient.isActive = true;
      await dbHelper.updatePatientIsActive(patient.id, true);
    }

    loadQueue(); // Reload the queue to reflect changes
    notifyListeners();
  }

  void _updateNextPatient() {
    if (_activeQueue.isNotEmpty) {
      _nextPatient = "Next Patient: ${_activeQueue.first.name} , Problem: ${_activeQueue.first.problem}";
    } else {
      _nextPatient = 'No patient in Queue';
    }
    notifyListeners();
  }

   void _updateCurrentPatient() {
    if (_activeQueue.isNotEmpty) {
      _currentPatient = "Current Patient: ${_activeQueue.first.name} , Problem: ${_activeQueue.first.problem}";
    } else {
      _currentPatient = 'No patient in Queue';
    }
    notifyListeners();
  }
}