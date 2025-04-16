// screens/device_mapping/device_mapping_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../models/room.dart';
import '../../models/device.dart';
import '../../models/circuit.dart';
import '../../services/panel_service.dart';

class DeviceMappingScreen extends StatefulWidget {
  final Room room;
  
  const DeviceMappingScreen({Key? key, required this.room}) : super(key: key);
  
  @override
  _DeviceMappingScreenState createState() => _DeviceMappingScreenState();
}

class _DeviceMappingScreenState extends State<DeviceMappingScreen> {
  final List<Device> _devices = [];
  Offset? _selectedPosition;
  DeviceType? _selectedDeviceType;
  
  @override
  void initState() {
    super.initState();
    _loadExistingDevices();
  }
  
  void _loadExistingDevices() async {
    // TODO: Load existing devices for this room
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Mapping: ${widget.room.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveDevices,
            tooltip: 'Save Devices',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Room floor plan background
          Image.file(
            File(widget.room.floorPlan),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          
          // Existing device markers
          ..._buildExistingDeviceMarkers(),
          
          // Selected position marker
          if (_selectedPosition != null)
            Positioned(
              left: _selectedPosition!.dx - 25,
              top: _selectedPosition!.dy - 25,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          
          // Tap to add device gesture detector
          Positioned.fill(
            child: GestureDetector(
              onTapUp: _handleTap,
            ),
          ),
        ],
      ),
      bottomSheet: _buildDeviceTypeSelector(),
    );
  }
  
  void _handleTap(TapUpDetails details) {
    if (_selectedDeviceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select a device type first')),
      );
      return;
    }
    
    setState(() {
      _selectedPosition = details.localPosition;
      _showAddDeviceDialog(details.localPosition);
    });
  }
  
  void _showAddDeviceDialog(Offset position) {
    final labelController = TextEditingController();
    final circuitController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${_selectedDeviceType.toString().split('.').last}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: 'Device Label',
                hintText: 'e.g. Living Room Lamp',
              ),
            ),
            SizedBox(height: 16),
            // Circuit selection dropdown
            Consumer<PanelService>(
              builder: (context, panelService, child) {
                // Assuming we have a way to get all circuits
                final allCircuits = panelService.panels
                    .expand((panel) => panelService.getCircuitsForPanel(panel.id!))
                    .toList();
                
                return DropdownButtonFormField<Circuit>(
                  decoration: InputDecoration(
                    labelText: 'Connected Circuit',
                  ),
                  items: allCircuits.map((circuit) {
                    return DropdownMenuItem(
                      value: circuit,
                      child: Text('${circuit.label} (${circuit.amperage}A)'),
                    );
                  }).toList(),
                  onChanged: (circuit) {
                    if (circuit != null) {
                      circuitController.text = circuit.id.toString();
                    }
                  },
                );
              },
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
              _addDevice(
                labelController.text, 
                int.parse(circuitController.text),
                position,
              );
              Navigator.of(context).pop();
            },
            child: Text('Add Device'),
          ),
        ],
      ),
    );
  }
  
  void _addDevice(String label, int circuitId, Offset position) {
    final newDevice = Device(
      roomId: widget.room.id!,
      circuitId: circuitId,
      type: _selectedDeviceType!,
      posX: position.dx,
      posY: position.dy,
      label: label,
    );
    
    setState(() {
      _devices.add(newDevice);
      _selectedPosition = null;
    });
  }
  
  List<Widget> _buildExistingDeviceMarkers() {
    return _devices.map((device) {
      return Positioned(
        left: device.posX - 25,
        top: device.posY - 25,
        child: GestureDetector(
          onTap: () => _showDeviceDetails(device),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getDeviceColor(device.type),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _getDeviceIcon(device.type),
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
  
  void _showDeviceDetails(Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(device.label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Type: ${device.type.toString().split('.').last}'),
            // Add more device details
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // Remove device
              setState(() {
                _devices.remove(device);
              });
              Navigator.of(context).pop();
            },
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }
  
  void _saveDevices() async {
    // TODO: Implement save logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Devices saved for ${widget.room.name}')),
    );
  }
  
  Widget _buildDeviceTypeSelector() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: DeviceType.values.map((type) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: ChoiceChip(
                label: Text(type.toString().split('.').last),
                selected: _selectedDeviceType == type,
                onSelected: (bool selected) {
                  setState(() {
                    _selectedDeviceType = selected ? type : null;
                  });
                },
                avatar: Icon(_getDeviceIcon(type)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  // Utility methods for device type visualization
  Color _getDeviceColor(DeviceType type) {
    switch (type) {
      case DeviceType.outlet:
        return Colors.blue;
      case DeviceType.switch_:
        return Colors.green;
      case DeviceType.light:
        return Colors.yellow.shade700;
      case DeviceType.appliance:
        return Colors.orange;
      case DeviceType.other:
        return Colors.grey;
    }
  }
  
  IconData _getDeviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.outlet:
        return Icons.power_outlined;
      case DeviceType.switch_:
        return Icons.toggle_on_outlined;
      case DeviceType.light:
        return Icons.lightbulb_outline;
      case DeviceType.appliance:
        return Icons.home_outlined;
      case DeviceType.other:
        return Icons.device_unknown;
    }
  }
}