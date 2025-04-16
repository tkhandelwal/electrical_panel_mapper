// screens/panel_details/panel_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../models/panel.dart';
import '../../models/circuit.dart';
import '../../services/panel_service.dart';
import '../panel_editor/circuit_form.dart';

class PanelDetailsScreen extends StatefulWidget {
  final Panel panel;
  
  const PanelDetailsScreen({Key? key, required this.panel}) : super(key: key);
  
  @override
  _PanelDetailsScreenState createState() => _PanelDetailsScreenState();
}

class _PanelDetailsScreenState extends State<PanelDetailsScreen> {
  bool _showLoadAnalysis = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.panel.name),
        actions: [
          IconButton(
            icon: Icon(Icons.insights),
            onPressed: () {
              setState(() {
                _showLoadAnalysis = !_showLoadAnalysis;
              });
            },
            tooltip: 'Panel Load Analysis',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showPanelSettings,
            tooltip: 'Panel Settings',
          ),
        ],
      ),
      body: Consumer<PanelService>(
        builder: (context, panelService, child) {
          final circuits = panelService.getCircuitsForPanel(widget.panel.id!);
          
          return Column(
            children: [
              // Panel Visualization
              Expanded(
                flex: 2,
                child: _buildPanelVisualization(circuits),
              ),
              
              // Load Analysis or Circuit List
              Expanded(
                flex: 1,
                child: _showLoadAnalysis
                    ? _buildLoadAnalysis(circuits)
                    : _buildCircuitList(circuits),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewCircuit(context),
        child: Icon(Icons.add),
        tooltip: 'Add Circuit',
      ),
    );
  }
  
  Widget _buildPanelVisualization(List<Circuit> circuits) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: PanelGridPainter(
            circuits: circuits,
            columns: 2, // Default to 2-column layout
          ),
          child: GestureDetector(
            onTapUp: (details) {
              // TODO: Implement circuit selection/editing on tap
            },
          ),
        );
      },
    );
  }
  
  Widget _buildLoadAnalysis(List<Circuit> circuits) {
    // Calculate total load and per-phase load
    double totalLoad = circuits.fold(0.0, (sum, circuit) {
      // Placeholder load calculation
      return sum + (circuit.amperage * 120 / 1000); // Convert to kW
    });
    
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panel Load Analysis',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Load:'),
                Text('${totalLoad.toStringAsFixed(2)} kW'),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: math.min(totalLoad / 20, 1), // Assuming 20kW max
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                totalLoad > 18 ? Colors.red : Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              totalLoad > 18 
                ? 'Warning: High Load Detected!' 
                : 'Panel Load Looks Good',
              style: TextStyle(
                color: totalLoad > 18 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCircuitList(List<Circuit> circuits) {
    return ListView.builder(
      itemCount: circuits.length,
      itemBuilder: (context, index) {
        final circuit = circuits[index];
        return ListTile(
          title: Text(circuit.label),
          subtitle: Text('${circuit.amperage} Amps'),
          trailing: Icon(
            circuit.isActive ? Icons.check_circle : Icons.warning,
            color: circuit.isActive ? Colors.green : Colors.orange,
          ),
          onTap: () => _editCircuit(context, circuit),
        );
      },
    );
  }
  
  void _addNewCircuit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CircuitForm(
        panelId: widget.panel.id!,
        onSave: (Circuit circuit) {
          Provider.of<PanelService>(context, listen: false).addCircuit(circuit);
        },
      ),
    );
  }
  
  void _editCircuit(BuildContext context, Circuit circuit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CircuitForm(
        panelId: widget.panel.id!,
        circuit: circuit,
        onSave: (Circuit updatedCircuit) {
          Provider.of<PanelService>(context, listen: false)
              .updateCircuit(updatedCircuit);
        },
      ),
    );
  }
  
  void _showPanelSettings() {
    // TODO: Implement panel settings dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Panel Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add panel settings options
            Text('Customize panel details, backup, etc.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Custom painter for panel grid visualization
class PanelGridPainter extends CustomPainter {
  final List<Circuit> circuits;
  final int columns;
  
  PanelGridPainter({
    required this.circuits,
    this.columns = 2,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final cellWidth = size.width / columns;
    final cellHeight = size.height / (circuits.length / columns).ceil();
    
    // Draw grid
    for (int i = 0; i <= columns; i++) {
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        paint,
      );
    }
    
    for (int i = 0; i <= circuits.length / columns; i++) {
      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.width, i * cellHeight),
        paint,
      );
    }
    
    // Draw circuit markers
    for (int i = 0; i < circuits.length; i++) {
      final circuit = circuits[i];
      final row = i ~/ columns;
      final col = i % columns;
      
      final cellRect = Rect.fromLTWH(
        col * cellWidth,
        row * cellHeight,
        cellWidth,
        cellHeight,
      );
      
      // Circuit marker
      final markerPaint = Paint()
        ..color = _getColorFromString(circuit.color)
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(
        cellRect.deflate(4),
        markerPaint,
      );
      
      // Circuit label
      final textPainter = TextPainter(
        text: TextSpan(
          text: circuit.label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: cellWidth - 8);
      
      textPainter.paint(
        canvas,
        Offset(
          cellRect.left + (cellWidth - textPainter.width) / 2,
          cellRect.top + (cellHeight - textPainter.height) / 2,
        ),
      );
    }
  }
  
  Color _getColorFromString(String colorStr) {
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
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}