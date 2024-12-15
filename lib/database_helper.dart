import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database; // Change to nullable

  Future<Database> get database async {
    // Initialize the database if it hasn't been initialized yet
    if (_database == null) {
      _database = await _initDatabase();
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(Directory.current.path, 'geomark.db'); // Use the current directory for server
    final db = sqlite3.open(path);
    _onCreate(db); // Create the tables if they don't exist
    return db;
  }

  void _onCreate(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS attendance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user TEXT,
        checkInTime TEXT,
        checkOutTime TEXT,
        date TEXT
      )
    ''');
  }

  Future<void> insertAttendance(Map<String, dynamic> data) async {
    final db = await database;
    try {
      db.execute('''
        INSERT INTO attendance (user, checkInTime, checkOutTime, date) 
        VALUES (?, ?, ?, ?)
      ''', [data['user'], data['checkInTime'], data['checkOutTime'], data['date']]);
    } catch (e) {
      print('Error inserting attendance: ${e.toString()}'); // Log the error
    }
  }

  Future<List<Map<String, dynamic>>> getAttendance() async {
    final db = await database;
    final result = db.select('SELECT * FROM attendance');
    return result.map((row) => {
      'id': row['id'],
      'user': row['user'],
      'checkInTime': row['checkInTime'],
      'checkOutTime': row['checkOutTime'],
      'date': row['date'],
    }).toList();
  }

  Future<void> updateAttendance(int id, Map<String, dynamic> data) async {
    final db = await database;
    try {
      db.execute('''
        UPDATE attendance 
        SET checkOutTime = ? 
        WHERE id = ?
      ''', [data['checkOutTime'], id]);
    } catch (e) {
      print('Error updating attendance: ${e.toString()}'); // Log the error
    }
  }

  Future<void> deleteAttendance(int id) async {
    final db = await database;
    try {
      db.execute('DELETE FROM attendance WHERE id = ?', [id]);
    } catch (e) {
      print('Error deleting attendance: ${e.toString()}'); // Log the error
    }
  }
}