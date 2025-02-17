class Patient {
  final int id;
  final String name;
  final String problem;
  final DateTime enqueueTime;
  final String? vaccinationType;
  final DateTime? vaccinationDate;
  String status;
  bool isActive; // Added isActive

  Patient({
    required this.id,
    required this.name,
    required this.problem,
    required this.enqueueTime,
    this.vaccinationType,
    this.vaccinationDate,
    this.status = 'Waiting',
    this.isActive = true, // Default to true
  });

  Patient.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        problem = map['problem'],
        enqueueTime = DateTime.fromMillisecondsSinceEpoch(map['enqueueTime']),
        vaccinationType = map['vaccinationType'],
        vaccinationDate = map['vaccinationDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['vaccinationDate'])
            : null,
        status = map['status'] ?? 'Waiting',
        isActive = map['is_active'] == 1; // Convert int to bool

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'problem': problem,
      'enqueueTime': enqueueTime.millisecondsSinceEpoch,
      'vaccinationType': vaccinationType,
      'vaccinationDate': vaccinationDate?.millisecondsSinceEpoch,
      'status': status,
      'is_active': isActive ? 1 : 0,  // Convert bool to int
    };
  }

  @override
  String toString() {
    return 'Patient{id: $id, name: $name, problem: $problem, enqueueTime: $enqueueTime, vaccinationType: $vaccinationType, vaccinationDate: $vaccinationDate, status: $status, isActive: $isActive}';
  }
}