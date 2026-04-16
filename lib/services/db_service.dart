// services/db_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:plant_disease_app/models/scan_result.dart';

class DbService {
  DbService._();
  static final DbService instance = DbService._();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'agrovision.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE scans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imagePath TEXT NOT NULL,
            plant TEXT NOT NULL,
            disease TEXT NOT NULL,
            confidence REAL NOT NULL,
            treatment TEXT NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Insert a new scan result
  Future<int> insertScan(ScanResult scan) async {
    final db = await database;
    return await db.insert(
      'scans',
      scan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all scans, newest first
  Future<List<ScanResult>> getAllScans() async {
    final db = await database;
    final maps = await db.query(
      'scans',
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => ScanResult.fromMap(m)).toList();
  }

  /// Delete a scan by id
  Future<void> deleteScan(int id) async {
    final db = await database;
    await db.delete('scans', where: 'id = ?', whereArgs: [id]);
  }

  /// Clear all scan history
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('scans');
  }
}