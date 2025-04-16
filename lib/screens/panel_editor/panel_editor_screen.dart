import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/panel.dart';
import '../../models/circuit.dart';
import '../../services/panel_service.dart';
import 'circuit_form.dart';

class PanelEditorScreen extends StatefulWidget {
  final Panel panel;
  
  const PanelEditorScreen({
    Key? key,
    required this.panel,
  }) : super(key: key);
  
  @override
  _PanelEditorScreenState createState() => _PanelEditorScreenState();
}

class _PanelEditorScreenState extends State<PanelEditorScreen> {
  // For selecting a position on the image
  Offset? _selectedPosition;
  bool _isAddingCircuit = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.panel.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _showEditPanelDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<PanelService>(
              builder: (context, panelService, child) {
                final circuits = panelService.getCircuitsForPanel(widget.panel.id!);
                
                return Stack(
                  children: [
                    // Panel image
                    GestureDetector(
                      onTapUp: _isAddingCircuit ? _handleImageTap : null,
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.file(
                          File(widget.panel.imagePath),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    
                    // Circuit markers
                    for (var circuit in circuits)
                      _buildCircuitMarker(circuit),
                      
                    // Selected position marker
                    if (_selectedPosition != null && _isAddingCircuit)
                      Positioned(
                        left: _selectedPosition!.dx - 15,
                        top: _selectedPosition!.dy - 15,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.5),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          
          // Bottom control panel
          Consumer<PanelService>(
            builder: (context, panelService, child) {
              final circuits = panelService.getCircuitsForPanel(widget.panel.id!);
              
              return Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Circuits (${circuits.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var circuit in circuits)
                            Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text(circuit.label),
                                backgroundColor: _getColorFromString(circuit.color),
                                deleteIcon: Icon(Icons.edit),
                                onDeleted: () => _editCircuit(circuit),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleAddCircuitMode,
        child: Icon(_isAddingCircuit ? Icons.close : Icons.add),
        tooltip: _isAddingCircuit ? 'Cancel' : 'Add Circuit',
      ),
    );
  }
  
  void _handleImageTap(TapUpDetails details) {
    setState(() {
      _selectedPosition = details.localPosition;
      _showAddCircuitDialog();
    });
  }
  
  void _toggleAddCircuitMode() {
    setState(() {
      _isAddingCircuit = !_isAddingCircuit;
      if (!_isAddingCircuit) {
        _selectedPosition = null;
      }
    });
  }
  
  Widget _buildCircuitMarker(Circuit circuit) {
    // This is a placeholder - in a real app you would store position data for each circuit
    // For now, we'll randomly position them
    final random = DateTime(circuit.id ?? 0).millisecondsSinceEpoch % 100;
    final size = MediaQuery.of(context).size;
    
    return Positioned(
      left: size.width * (0.2 + (random / 100) * 0.6),
      top: size.height * 0.3 * (0.2 + (random / 100) * 0.6),
      child: GestureDetector(
        onTap: () => _editCircuit(circuit),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _getColorFromString(circuit.color),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              circuit.label.substring(0, 1),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _showAddCircuitDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CircuitForm(
        panelId: widget.panel.id!,
        onSave: (Circuit circuit) {
          Provider.of<PanelService>(context, listen: false).addCircuit(circuit);
          _toggleAddCircuitMode();
        },
      ),
    );
  }
  
  void _editCircuit(Circuit circuit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CircuitForm(
        panelId: widget.panel.id!,
        circuit: circuit,
        onSave: (Circuit updatedCircuit) {
          // This would need to be implemented in the panel service
          Provider.of<PanelService>(context, listen: false).updateCircuit(updatedCircuit);
        },
      ),
    );
  }
  
  void _showEditPanelDialog() {
    final nameController = TextEditingController(text: widget.panel.name);
    final locationController = TextEditingController(text: widget.panel.location);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Panel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Panel Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Panel Location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedPanel = Panel(
                id: widget.panel.id,
                name: nameController.text,
                imagePath: widget.panel.imagePath,
                location: locationController.text,
                circuitIds: widget.panel.circuitIds,
                createdAt: widget.panel.createdAt,
                updatedAt: DateTime.now(),
              );
              
              Provider.of<PanelService>(context, listen: false).updatePanel(updatedPanel);
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
  
  Color _getColorFromString(String colorStr) {
    // Simple implementation - in a real app, you'd store actual color values
    switch (colorStr.toLowerCase()) {
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'orange': return Colors.orange;
      case 'purple': return Colors.purple;
      case 'yellow': return Colors.yellow;
      default: return Colors.grey;
    }
  }
}