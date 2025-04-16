import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

import '../models/panel.dart';
import '../models/circuit.dart';
import '../models/room.dart';
import '../models/device.dart';

class AdvancedDatabaseService {
  static final AdvancedDatabaseService _instance = AdvancedDatabaseService._internal();
  static Database? _database;

  factory AdvancedDatabaseService() {
    return _instance;
  }

  AdvancedDatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'advanced_electrical_panel.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Panels table with extended metadata
    await db.execute('''
      CREATE TABLE panels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        imagePath TEXT,
        location TEXT,
        circuitIds TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        mainAmperage INTEGER,
        phase TEXT,
        voltage INTEGER,
        mainBreakerType TEXT,
        notes TEXT
      )
    ''');

    // Circuits table with enhanced tracking
    await db.execute('''
      CREATE TABLE circuits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        panelId INTEGER,
        label TEXT,
        amperage INTEGER,
        color TEXT,
        deviceIds TEXT,
        isActive INTEGER,
        metadata TEXT,
        phase TEXT,
        isGFCI INTEGER,
        isArc INTEGER,
        loadCurrent REAL,
        installationDate TEXT
      )
    ''');

    // Rooms table with floor plan support
    await db.execute('''
      CREATE TABLE rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        floorPlan TEXT,
        deviceIds TEXT,
        squareFootage REAL,
        electricalLoadCapacity REAL
      )
    ''');

    // Devices table with comprehensive details
    await db.execute('''
      CREATE TABLE devices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        roomId INTEGER,
        circuitId INTEGER,
        type TEXT,
        posX REAL,
        posY REAL,
        label TEXT,
        manufacturer TEXT,
        modelNumber TEXT,
        serialNumber TEXT,
        wattage REAL,
        voltage INTEGER,
        amperage REAL,
        installationDate TEXT,
        lastMaintenanceDate TEXT,
        notes TEXT
      )
    ''');

    // Energy monitoring table
    await db.execute('''
      CREATE TABLE energy_monitoring (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        circuitId INTEGER,
        timestamp TEXT,
        currentLoad REAL,
        voltage REAL,
        powerFactor REAL,
        energyConsumed REAL
      )
    ''');

    // Maintenance log table
    await db.execute('''
      CREATE TABLE maintenance_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deviceId INTEGER,
        circuitId INTEGER,
        panelId INTEGER,
        maintenanceType TEXT,
        description TEXT,
        performedBy TEXT,
        maintenanceDate TEXT,
        nextMaintenanceDate TEXT,
        cost REAL,
        notes TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns or create new tables as needed
      await db.execute('ALTER TABLE circuits ADD COLUMN loadCurrent REAL');
      await db.execute('ALTER TABLE devices ADD COLUMN serialNumber TEXT');
    }

    if (oldVersion < 3) {
      // More potential upgrades
      await db.execute('ALTER TABLE panels ADD COLUMN mainBreakerType TEXT');
      await db.execute('ALTER TABLE devices ADD COLUMN lastMaintenanceDate TEXT');
    }
  }

  // Comprehensive CRUD operations for each entity

  // Panel Operations
  Future<int> insertPanel(Map<String, dynamic> panel) async {
    final db = await database;
    return await db.insert('panels', panel, 
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllPanels() async {
    final db = await database;
    return await db.query('panels');
  }

  Future<Map<String, dynamic>?> getPanelById(int id) async {
    final db = await database;
    final results = await db.query(
      'panels',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Circuit Operations
  Future<int> insertCircuit(Map<String, dynamic> circuit) async {
    final db = await database;
    return await db.insert('circuits', circuit, 
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getCircuitsByPanelId(int panelId) async {
    final db = await database;
    return await db.query(
      'circuits',
      where: 'panelId = ?',
      whereArgs: [panelId],
    );
  }

  // Device Operations
  Future<int> insertDevice(Map<String, dynamic> device) async {
    final db = await database;
    return await db.insert('devices', device, 
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getDevicesByRoomId(int roomId) async {
    final db = await database;
    return await db.query(
      'devices',
      where: 'roomId = ?',
      whereArgs: [roomId],
    );
  }

  // Energy Monitoring Operations
  Future<int> insertEnergyReading(Map<String, dynamic> reading) async {
    final db = await database;
    return await db.insert('energy_monitoring', reading);
  }

  Future<List<Map<String, dynamic>>> getEnergyReadingsByCircuit(
    int circuitId, 
    {DateTime? startDate, 
    DateTime? endDate}
  ) async {
    final db = await database;
    
    final whereClause = startDate != null && endDate != null
      ? 'circuitId = ? AND timestamp BETWEEN ? AND ?'
      : 'circuitId = ?';
    
    final whereArgs = startDate != null && endDate != null
      ? [
          circuitId, 
          startDate.toIso8601String(), 
          endDate.toIso8601String()
        ]
      : [circuitId];
    
    return await db.query(
      'energy_monitoring',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );
  }

  // Maintenance Log Operations
  Future<int> insertMaintenanceLog(Map<String, dynamic> log) async {
    final db = await database;
    return await db.insert('maintenance_logs', log);
  }

  Future<List<Map<String, dynamic>>> getMaintenanceLogsByDevice(int deviceId) async {
    final db = await database;
    return await db.query(
      'maintenance_logs',
      where: 'deviceId = ?',
      whereArgs: [deviceId],
      orderBy: 'maintenanceDate DESC',
    );
  }

  // Advanced Search and Filtering
  Future<List<Map<String, dynamic>>> searchPanels(String query) async {
    final db = await database;
    return await db.query(
      'panels',
      where: 'name LIKE ? OR location LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

  Future<List<Map<String, dynamic>>> searchDevices(String query) async {
    final db = await database;
    return await db.query(
      'devices',
      where: 'label LIKE ? OR manufacturer LIKE ? OR modelNumber LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
  }

  // Backup and Export
  Future<Map<String, dynamic>> exportDatabaseData() async {
    final db = await database;
    
    return {
      'panels': await db.query('panels'),
      'circuits': await db.query('circuits'),
      'rooms': await db.query('rooms'),
      'devices': await db.query('devices'),
      'energy_monitoring': await db.query('energy_monitoring'),
      'maintenance_logs': await db.query('maintenance_logs'),
    };
  }

  // Import data (useful for backup restoration)
  Future<void> importDatabaseData(Map<String, dynamic> data) async {
    final db = await database;
    
    // Clear existing data
    await db.delete('panels');
    await db.delete('circuits');
    await db.delete('rooms');
    await db.delete('devices');
    await db.delete('energy_monitoring');
    await db.delete('maintenance_logs');
    
    // Insert imported data
    final batch = db.batch();
    
    (data['panels'] as List).forEach((panel) {
      batch.insert('panels', panel);
    });
    
    (data['circuits'] as List).forEach((circuit) {
      batch.insert('circuits', circuit);
    });
    
    (data['rooms'] as List).forEach((room) {
      batch.insert('rooms', room);
    });
    
    (data['devices'] as List).forEach((device) {
      batch.insert('devices', device);
    });
    
    (data['energy_monitoring'] as List).forEach((reading) {
      batch.insert('energy_monitoring', reading);
    });
    
    (data['maintenance_logs'] as List).forEach((log) {
      batch.insert('maintenance_logs', log);
    });
    
    await batch.commit(noResult: true);
  }

  // Utility method to clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('panels');
    await db.delete('circuits');
    await db.delete('rooms');
    await db.delete('devices');
    await db.delete('energy_monitoring');
    await db.delete('maintenance_logs');
  }

  // Close the database
  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}