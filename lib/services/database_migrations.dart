// services/database_migrations.dart
import 'dart:convert';

import 'package:electrical_panel_mapper/models/device.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseMigrations {
  // Method to handle database schema migrations
  static Future<void> migrateDatabaseSchema(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add panel metadata table
      await db.execute('''
        CREATE TABLE panel_metadata(
          panelId INTEGER PRIMARY KEY,
          mainAmperage INTEGER,
          phase TEXT,
          voltage INTEGER,
          mainBreakerType TEXT,
          notes TEXT
        )
      ''');
      
      // Modify circuits table to add more detailed information
      await db.execute('''
        ALTER TABLE circuits 
        ADD COLUMN phase TEXT DEFAULT 'Single';
      ''');
      
      await db.execute('''
        ALTER TABLE circuits 
        ADD COLUMN isGFCI INTEGER DEFAULT 0;
      ''');
      
      await db.execute('''
        ALTER TABLE circuits 
        ADD COLUMN isArc INTEGER DEFAULT 0;
      ''');
      
      await db.execute('''
        ALTER TABLE circuits 
        ADD COLUMN loadCurrent REAL DEFAULT 0.0;
      ''');
    }
    
    if (oldVersion < 3) {
      // Create energy monitoring table
      await db.execute('''
        CREATE TABLE energy_monitoring(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          circuitId INTEGER,
          timestamp TEXT,
          currentLoad REAL,
          voltage REAL,
          powerFactor REAL
        )
      ''');
      
      // Create panel layout table
      await db.execute('''
        CREATE TABLE panel_layouts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          panelId INTEGER,
          columns INTEGER,
          rows INTEGER,
          layoutData TEXT
        )
      ''');
    }
    
    if (oldVersion < 4) {
      // Add more detailed device information
      await db.execute('''
        ALTER TABLE devices 
        ADD COLUMN manufacturer TEXT;
      ''');
      
      await db.execute('''
        ALTER TABLE devices 
        ADD COLUMN modelNumber TEXT;
      ''');
      
      await db.execute('''
        ALTER TABLE devices 
        ADD COLUMN wattage REAL;
      ''');
      
      await db.execute('''
        ALTER TABLE devices 
        ADD COLUMN voltage INTEGER;
      ''');
    }
  }
}

// Enhanced Circuit Model with Migration Support
class MigratedCircuit {
  final int? id;
  final int panelId;
  final String label;
  final int amperage;
  final String color;
  final List<int> deviceIds;
  final bool isActive;
  final Map<String, dynamic> metadata;
  
  // New fields for enhanced circuit tracking
  final String phase;
  final bool isGFCI;
  final bool isArc;
  final double loadCurrent;
  
  MigratedCircuit({
    this.id,
    required this.panelId,
    required this.label,
    required this.amperage,
    required this.color,
    this.deviceIds = const [],
    this.isActive = true,
    this.metadata = const {},
    this.phase = 'Single',
    this.isGFCI = false,
    this.isArc = false,
    this.loadCurrent = 0.0,
  });
  
  // Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'panelId': panelId,
      'label': label,
      'amperage': amperage,
      'color': color,
      'deviceIds': deviceIds.isEmpty ? '' : deviceIds.join(','),
      'isActive': isActive ? 1 : 0,
      'metadata': metadata.isEmpty ? null : jsonEncode(metadata),
      'phase': phase,
      'isGFCI': isGFCI ? 1 : 0,
      'isArc': isArc ? 1 : 0,
      'loadCurrent': loadCurrent,
    };
  }
  
  // Create from map (for database retrieval)
  factory MigratedCircuit.fromMap(Map<String, dynamic> map) {
    return MigratedCircuit(
      id: map['id'],
      panelId: map['panelId'],
      label: map['label'],
      amperage: map['amperage'],
      color: map['color'],
      deviceIds: map['deviceIds'] != null && map['deviceIds'].toString().isNotEmpty 
          ? map['deviceIds'].toString().split(',')
              .where((e) => e.isNotEmpty)
              .map((e) => int.parse(e)).toList() 
          : [],
      isActive: map['isActive'] == 1,
      metadata: map['metadata'] != null && map['metadata'].toString().isNotEmpty
          ? (map['metadata'] is String 
              ? jsonDecode(map['metadata']) as Map<String, dynamic>
              : map['metadata'] as Map<String, dynamic>)
          : {},
      phase: map['phase'] ?? 'Single',
      isGFCI: map['isGFCI'] == 1,
      isArc: map['isArc'] == 1,
      loadCurrent: (map['loadCurrent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Enhanced Device Model
class MigratedDevice {
  final int? id;
  final int roomId;
  final int circuitId;
  final DeviceType type;
  final double posX;
  final double posY;
  final String label;
  
  // New fields for more detailed device tracking
  final String? manufacturer;
  final String? modelNumber;
  final double? wattage;
  final int? voltage;
  
  MigratedDevice({
    this.id,
    required this.roomId,
    required this.circuitId,
    required this.type,
    required this.posX,
    required this.posY,
    required this.label,
    this.manufacturer,
    this.modelNumber,
    this.wattage,
    this.voltage,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'circuitId': circuitId,
      'type': type.toString().split('.').last,
      'posX': posX,
      'posY': posY,
      'label': label,
      'manufacturer': manufacturer,
      'modelNumber': modelNumber,
      'wattage': wattage,
      'voltage': voltage,
    };
  }
  
  factory MigratedDevice.fromMap(Map<String, dynamic> map) {
    return MigratedDevice(
      id: map['id'],
      roomId: map['roomId'],
      circuitId: map['circuitId'],
      type: DeviceType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => DeviceType.other,
      ),
      posX: map['posX'],
      posY: map['posY'],
      label: map['label'],
      manufacturer: map['manufacturer'],
      modelNumber: map['modelNumber'],
      wattage: (map['wattage'] as num?)?.toDouble(),
      voltage: map['voltage'] as int?,
    );
  }
}