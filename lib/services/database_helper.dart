import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "smallclinic_database.db";
  static const _databaseVersion = 4; // Increment version!

  late Database _db;

  Future<void> initializeDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = '${documentsDirectory.path}/$_databaseName';
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        problem TEXT NOT NULL,
        enqueueTime INTEGER NOT NULL,
        vaccinationType TEXT,
        vaccinationDate INTEGER,
        status TEXT NOT NULL DEFAULT 'Waiting',
        is_active INTEGER NOT NULL DEFAULT 1
      )
      ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
     if (oldVersion < 2) {
      // Add the new columns
      await db.execute('ALTER TABLE patients ADD COLUMN vaccinationType TEXT');
      await db.execute('ALTER TABLE patients ADD COLUMN vaccinationDate INTEGER');
    }
     if (oldVersion < 3) {
      // Add the status column
      await db.execute('ALTER TABLE patients ADD COLUMN status TEXT NOT NULL DEFAULT \'Waiting\'');
    }
    if (oldVersion < 4) {
      // Add the is_active column
      await db.execute('ALTER TABLE patients ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1');
    }
  }

  Future<int> insertPatient(
      {required String name,
      required String problem,
      String? vaccinationType,
      DateTime? vaccinationDate}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return await _db.insert(
      'patients',
      {
        'name': name,
        'problem': problem,
        'enqueueTime': now,
        'vaccinationType': vaccinationType,
        'vaccinationDate': vaccinationDate?.millisecondsSinceEpoch,
        'status': 'Waiting', // Default status
        'is_active': 1, // Default to active
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPatients() async {
    return await _db.query('patients',  orderBy: 'enqueueTime ASC');
  }

  Future<Map<String, dynamic>?> getPatientById(String patientId) async {
    List<Map<String, dynamic>> result = await _db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [int.parse(patientId)],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> deletePatient(int id) async {
    return await _db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updatePatientStatus(int id, String status) async {
    return await _db.update(
      'patients',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

Future<int> updatePatientIsActive(int id, bool isActive) async {
    return await _db.update(
      'patients',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<int> updatePatient({
    required int id,
    required String name,
    required String problem,
    String? vaccinationType,
    DateTime? vaccinationDate,
  }) async {
    return await _db.update(
      'patients',
      {
        'name': name,
        'problem': problem,
        'vaccinationType': vaccinationType,
        'vaccinationDate': vaccinationDate?.millisecondsSinceEpoch
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    await _db.close();
  }
}