import 'package:flutter/foundation.dart';
import '../models/panel.dart';
import '../models/circuit.dart';
import 'database_service.dart';

class PanelService extends ChangeNotifier {
  final DatabaseService _databaseService;
  List<Panel> _panels = [];
  Map<int, List<Circuit>> _circuits = {};

  PanelService(this._databaseService) {
    _loadPanels();
  }

  List<Panel> get panels => _panels;
  
  List<Circuit> getCircuitsForPanel(int panelId) {
    return _circuits[panelId] ?? [];
  }

  Future<void> _loadPanels() async {
    _panels = await _databaseService.getPanels();
    
    // Load circuits for each panel
    for (var panel in _panels) {
      await _loadCircuitsForPanel(panel.id!);
    }
    notifyListeners();
  }

  Future<void> _loadCircuitsForPanel(int panelId) async {
    final circuits = await _databaseService.getCircuitsByPanelId(panelId);
    _circuits[panelId] = circuits;
  }

  Future<void> addPanel(Panel panel) async {
    final id = await _databaseService.insertPanel(panel);
    final newPanel = Panel(
      id: id,
      name: panel.name,
      imagePath: panel.imagePath,
      location: panel.location,
      circuitIds: panel.circuitIds,
      createdAt: panel.createdAt,
      updatedAt: panel.updatedAt,
    );
    
    _panels.add(newPanel);
    _circuits[id] = [];
    notifyListeners();
  }

  Future<void> updatePanel(Panel panel) async {
    await _databaseService.updatePanel(panel);
    
    final index = _panels.indexWhere((p) => p.id == panel.id);
    if (index != -1) {
      _panels[index] = panel;
      notifyListeners();
    }
  }

  Future<void> deletePanel(int id) async {
    await _databaseService.deletePanel(id);
    
    _panels.removeWhere((panel) => panel.id == id);
    _circuits.remove(id);
    notifyListeners();
  }

  Future<void> addCircuit(Circuit circuit) async {
    final id = await _databaseService.insertCircuit(circuit);
    final newCircuit = Circuit(
      id: id,
      panelId: circuit.panelId,
      label: circuit.label,
      amperage: circuit.amperage,
      color: circuit.color,
      deviceIds: circuit.deviceIds,
      isActive: circuit.isActive,
    );
    
    if (_circuits.containsKey(circuit.panelId)) {
      _circuits[circuit.panelId]!.add(newCircuit);
    } else {
      _circuits[circuit.panelId] = [newCircuit];
    }
    
    // Update the panel's circuitIds
    final panelIndex = _panels.indexWhere((p) => p.id == circuit.panelId);
    if (panelIndex != -1) {
      final panel = _panels[panelIndex];
      final updatedPanel = Panel(
        id: panel.id,
        name: panel.name,
        imagePath: panel.imagePath,
        location: panel.location,
        circuitIds: [...panel.circuitIds, id],
        createdAt: panel.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await updatePanel(updatedPanel);
    }
    
    notifyListeners();
  }

  Future<void> updateCircuit(Circuit circuit) async {
    await _databaseService.updateCircuit(circuit);
    
    if (_circuits.containsKey(circuit.panelId)) {
      final circuits = _circuits[circuit.panelId]!;
      final index = circuits.indexWhere((c) => c.id == circuit.id);
      
      if (index != -1) {
        circuits[index] = circuit;
        notifyListeners();
      }
    }
  }

  Future<void> deleteCircuit(int id, int panelId) async {
    await _databaseService.deleteCircuit(id);
    
    if (_circuits.containsKey(panelId)) {
      _circuits[panelId]!.removeWhere((circuit) => circuit.id == id);
      
      // Update the panel's circuitIds
      final panelIndex = _panels.indexWhere((p) => p.id == panelId);
      if (panelIndex != -1) {
        final panel = _panels[panelIndex];
        final updatedPanel = Panel(
          id: panel.id,
          name: panel.name,
          imagePath: panel.imagePath,
          location: panel.location,
          circuitIds: panel.circuitIds.where((circuitId) => circuitId != id).toList(),
          createdAt: panel.createdAt,
          updatedAt: DateTime.now(),
        );
        
        await updatePanel(updatedPanel);
      }
      
      notifyListeners();
    }
  }
  
  // Get a single circuit by ID
  Circuit? getCircuit(int id, int panelId) {
    if (_circuits.containsKey(panelId)) {
      return _circuits[panelId]!.firstWhere(
        (circuit) => circuit.id == id,
        orElse: () => null as Circuit,
      );
    }
    return null;
  }
  
  // Refresh all data (useful after major changes)
  Future<void> refreshData() async {
    await _loadPanels();
  }
}

// Extension of DatabaseService for circuits
extension CircuitDatabase on DatabaseService {
  Future<List<Circuit>> getCircuitsByPanelId(int panelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'circuits',
      where: 'panelId = ?',
      whereArgs: [panelId],
    );
    
    return List.generate(maps.length, (i) => Circuit.fromMap(maps[i]));
  }
  
  Future<int> insertCircuit(Circuit circuit) async {
    final db = await database;
    return await db.insert('circuits', circuit.toMap());
  }
  
  Future<int> updateCircuit(Circuit circuit) async {
    final db = await database;
    return await db.update(
      'circuits',
      circuit.toMap(),
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
  
  Future<Circuit?> getCircuit(int id) async {
    final db = await database;
    final maps = await db.query(
      'circuits',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Circuit.fromMap(maps.first);
    }
    return null;
  }
}