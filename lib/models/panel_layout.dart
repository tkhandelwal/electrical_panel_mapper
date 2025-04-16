// models/panel_layout.dart
import 'package:electrical_panel_mapper/models/circuit.dart';

class PanelLayout {
  final int panelId;
  final int columns;
  final int rows;
  final List<CircuitPosition> circuitPositions;
  
  PanelLayout({
    required this.panelId,
    required this.columns,
    required this.rows,
    this.circuitPositions = const [],
  });
  
  // Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'panelId': panelId,
      'columns': columns,
      'rows': rows,
      'circuitPositions': circuitPositions.map((cp) => cp.toMap()).toList(),
    };
  }
  
  // Create from map (for database retrieval)
  factory PanelLayout.fromMap(Map<String, dynamic> map) {
    return PanelLayout(
      panelId: map['panelId'],
      columns: map['columns'],
      rows: map['rows'],
      circuitPositions: (map['circuitPositions'] as List)
          .map((cp) => CircuitPosition.fromMap(cp))
          .toList(),
    );
  }
}

// Represents the position of a circuit in the panel grid
class CircuitPosition {
  final int circuitId;
  final int row;
  final int column;
  final bool isDouble; // Some breakers take up two slots
  
  CircuitPosition({
    required this.circuitId,
    required this.row,
    required this.column,
    this.isDouble = false,
  });
  
  // Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'circuitId': circuitId,
      'row': row,
      'column': column,
      'isDouble': isDouble ? 1 : 0,
    };
  }
  
  // Create from map (for database retrieval)
  factory CircuitPosition.fromMap(Map<String, dynamic> map) {
    return CircuitPosition(
      circuitId: map['circuitId'],
      row: map['row'],
      column: map['column'],
      isDouble: map['isDouble'] == 1,
    );
  }
}

// Enhanced Circuit model with more detailed information
class EnhancedCircuit extends Circuit {
  final String phase; // Single or three-phase
  final bool isGFCI; // Ground Fault Circuit Interrupter
  final bool isArc; // Arc Fault Circuit Interrupter
  final double loadCurrent; // Current load on the circuit
  
  EnhancedCircuit({
    super.id,
    required super.panelId,
    required super.label,
    required super.amperage,
    required super.color,
    super.deviceIds,
    super.isActive,
    super.metadata,
    this.phase = 'Single',
    this.isGFCI = false,
    this.isArc = false,
    this.loadCurrent = 0.0,
  });
  
  // Override toMap to include new fields
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['phase'] = phase;
    map['isGFCI'] = isGFCI ? 1 : 0;
    map['isArc'] = isArc ? 1 : 0;
    map['loadCurrent'] = loadCurrent;
    return map;
  }
  
  // Override fromMap to create from enhanced map
  factory EnhancedCircuit.fromMap(Map<String, dynamic> map) {
    return EnhancedCircuit(
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
      metadata: map['metadata'] ?? {},
      phase: map['phase'] ?? 'Single',
      isGFCI: map['isGFCI'] == 1,
      isArc: map['isArc'] == 1,
      loadCurrent: (map['loadCurrent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}