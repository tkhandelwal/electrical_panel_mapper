import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/panel.dart';
import '../models/circuit.dart';
import '../models/room.dart';
import '../models/device.dart';

class DatabaseService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'electrical_panel_mapper.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE panels(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        imagePath TEXT,
        location TEXT,
        circuitIds TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE circuits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        panelId INTEGER,
        label TEXT,
        amperage INTEGER,
        color TEXT,
        deviceIds TEXT,
        isActive INTEGER,
        metadata TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE rooms(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        floorPlan TEXT,
        deviceIds TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE devices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        roomId INTEGER,
        circuitId INTEGER,
        type TEXT,
        posX REAL,
        posY REAL,
        label TEXT
      )
    ''');
  }

  // Panel CRUD operations
  Future<int> insertPanel(Panel panel) async {
    final db = await database;
    return await db.insert('panels', panel.toMap());
  }

  Future<List<Panel>> getPanels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('panels');
    return List.generate(maps.length, (i) => Panel.fromMap(maps[i]));
  }
  
  Future<Panel?> getPanel(int id) async {
    final db = await database;
    final maps = await db.query(
      'panels',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Panel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePanel(Panel panel) async {
    final db = await database;
    return await db.update(
      'panels',
      panel.toMap(),
      where: 'id = ?',
      whereArgs: [panel.id],
    );
  }

  Future<int> deletePanel(int id) async {
    final db = await database;
    return await db.delete(
      'panels',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Circuit CRUD operations
  Future<int> insertCircuit(Circuit circuit) async {
    final db = await database;
    Map<String, dynamic> circuitMap = circuit.toMap();
    if (circuitMap.containsKey('metadata') && circuitMap['metadata'] is Map) {
      circuitMap['metadata'] = jsonEncode(circuitMap['metadata']);
    }
    return await db.insert('circuits', circuitMap);
  }

  Future<List<Circuit>> getCircuitsByPanelId(int panelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'circuits',
      where: 'panelId = ?',
      whereArgs: [panelId],
    );
    
    return List.generate(maps.length, (i) {
      Map<String, dynamic> map = maps[i];
      if (map.containsKey('metadata') && map['metadata'] != null) {
        try {
          map['metadata'] = jsonDecode(map['metadata']);
        } catch (e) {
          map['metadata'] = {};
        }
      } else {
        map['metadata'] = {};
      }
      return Circuit.fromMap(map);
    });
  }
  
  Future<Circuit?> getCircuit(int id) async {
    final db = await database;
    final maps = await db.query(
      'circuits',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      Map<String, dynamic> map = maps.first;
      if (map.containsKey('metadata') && map['metadata'] != null) {
        try {
          map['metadata'] = jsonDecode(map['metadata']);
        } catch (e) {
          map['metadata'] = {};
        }
      } else {
        map['metadata'] = {};
      }
      return Circuit.fromMap(map);
    }
    return null;
  }

  Future<int> updateCircuit(Circuit circuit) async {
    final db = await database;
    Map<String, dynamic> circuitMap = circuit.toMap();
    if (circuitMap.containsKey('metadata') && circuitMap['metadata'] is Map) {
      circuitMap['metadata'] = jsonEncode(circuitMap['metadata']);
    }
    return await db.update(
      'circuits',
      circuitMap,
      where: 'id = ?',
      whereArgs: [circuit.id],
    );
  }

  Future<int> deleteCircuit(int id) async {
    final db = await database;
    return await db.delete(
      'circuits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Room CRUD operations
  Future<int> insertRoom(Room room) async {
    final db = await database;
    return await db.insert('rooms', room.toMap());
  }

  Future<List<Room>> getRooms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('rooms');
    return List.generate(maps.length, (i) => Room.fromMap(maps[i]));
  }
  
  Future<Room?> getRoom(int id) async {
    final db = await database;
    final maps = await db.query(
      'rooms',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Room.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateRoom(Room room) async {
    final db = await database;
    return await db.update(
      'rooms',
      room.toMap(),
      where: 'id = ?',
      whereArgs: [room.id],
    );
  }

  Future<int> deleteRoom(int id) async {
    final db = await database;
    return await db.delete(
      'rooms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Device CRUD operations
  Future<int> insertDevice(Device device) async {
    final db = await database;
    return await db.insert('devices', device.toMap());
  }

  Future<List<Device>> getDevicesByRoomId(int roomId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'devices',
      where: 'roomId = ?',
      whereArgs: [roomId],
    );
    
    return List.generate(maps.length, (i) => Device.fromMap(maps[i]));
  }
  
  Future<List<Device>> getDevicesByCircuitId(int circuitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'devices',
      where: 'circuitId = ?',
      whereArgs: [circuitId],
    );
    
    return List.generate(maps.length, (i) => Device.fromMap(maps[i]));
  }
  
  Future<Device?> getDevice(int id) async {
    final db = await database;
    final maps = await db.query(
      'devices',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Device.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateDevice(Device device) async {
    final db = await database;
    return await db.update(
      'devices',
      device.toMap(),
      where: 'id = ?',
      whereArgs: [device.id],
    );
  }

  Future<int> deleteDevice(int id) async {
    final db = await database;
    return await db.delete(
      'devices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Utility methods
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('panels');
    await db.delete('circuits');
    await db.delete('rooms');
    await db.delete('devices');
  }
  
  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
  
  // Backup and restore functionality
  Future<Map<String, dynamic>> exportData() async {
    final db = await database;
    
    final panels = await db.query('panels');
    final circuits = await db.query('circuits');
    final rooms = await db.query('rooms');
    final devices = await db.query('devices');
    
    return {
      'panels': panels,
      'circuits': circuits,
      'rooms': rooms,
      'devices': devices,
    };
  }
  
  Future<void> importData(Map<String, dynamic> data) async {
    final db = await database;
    
    // Clear existing data
    await clearDatabase();
    
    // Insert imported data
    for (var panel in data['panels']) {
      await db.insert('panels', panel);
    }
    
    for (var circuit in data['circuits']) {
      await db.insert('circuits', circuit);
    }
    
    for (var room in data['rooms']) {
      await db.insert('rooms', room);
    }
    
    for (var device in data['devices']) {
      await db.insert('devices', device);
    }
  }
  
  // Search functionality
  Future<List<Panel>> searchPanels(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'panels',
      where: 'name LIKE ? OR location LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    
    return List.generate(maps.length, (i) => Panel.fromMap(maps[i]));
  }
  
  Future<List<Circuit>> searchCircuits(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'circuits',
      where: 'label LIKE ?',
      whereArgs: ['%$query%'],
    );
    
    return List.generate(maps.length, (i) {
      Map<String, dynamic> map = maps[i];
      if (map.containsKey('metadata') && map['metadata'] != null) {
        try {
          map['metadata'] = jsonDecode(map['metadata']);
        } catch (e) {
          map['metadata'] = {};
        }
      } else {
        map['metadata'] = {};
      }
      return Circuit.fromMap(map);
    });
  }
  
  Future<List<Device>> searchDevices(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'devices',
      where: 'label LIKE ? OR type LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    
    return List.generate(maps.length, (i) => Device.fromMap(maps[i]));
  }
}