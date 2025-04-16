import 'package:flutter/material.dart';
import '../../models/circuit.dart';

class CircuitForm extends StatefulWidget {
  final int panelId;
  final Circuit? circuit;
  final Function(Circuit) onSave;
  final int? position; // Added for manual panels
  
  const CircuitForm({
    super.key,
    required this.panelId,
    this.circuit,
    required this.onSave,
    this.position,
  });
  
  @override
  CircuitFormState createState() => CircuitFormState();
}

class CircuitFormState extends State<CircuitForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late int _amperage;
  String _color = 'blue';
  bool _isActive = true;
  
  final List<int> _availableAmperages = [15, 20, 30, 40, 50, 60, 70, 100];
  final List<String> _availableColors = ['red', 'green', 'blue', 'orange', 'purple', 'yellow'];
  
  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.circuit?.label ?? '');
    _amperage = widget.circuit?.amperage ?? 15;
    _color = widget.circuit?.color ?? 'blue';
    _isActive = widget.circuit?.isActive ?? true;
  }
  
  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.circuit == null ? 'Add Circuit' : 'Edit Circuit',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: 'Circuit Label',
                hintText: 'e.g. Living Room Outlets, Kitchen Lights',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a circuit label';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _amperage,
              decoration: InputDecoration(
                labelText: 'Amperage',
                border: OutlineInputBorder(),
              ),
              items: _availableAmperages.map((amp) {
                return DropdownMenuItem<int>(
                  value: amp,
                  child: Text('$amp Amps'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _amperage = value;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            Text('Circuit Color'),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _color = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getColorFromString(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _color == color ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: _color == color
                          ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Circuit Active'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveCircuit,
                  child: Text('Save'),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  void _saveCircuit() {
    if (_formKey.currentState!.validate()) {
      // Create metadata to store position if needed
      Map<String, dynamic> metadata = widget.circuit?.metadata ?? {};
      if (widget.position != null) {
        metadata['position'] = widget.position;
      }
      
      final circuit = Circuit(
        id: widget.circuit?.id,
        panelId: widget.panelId,
        label: _labelController.text,
        amperage: _amperage,
        color: _color,
        deviceIds: widget.circuit?.deviceIds ?? [],
        isActive: _isActive,
        metadata: metadata,
      );
      
      widget.onSave(circuit);
      Navigator.of(context).pop();
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
}