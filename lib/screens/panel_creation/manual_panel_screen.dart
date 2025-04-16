// screens/panel_creation/manual_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/panel.dart';
import '../../models/panel_template.dart';
import '../../services/panel_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:ui' as ui;

class ManualPanelScreen extends StatefulWidget {
  const ManualPanelScreen({super.key});

  @override
  ManualPanelScreenState createState() => ManualPanelScreenState();
}

class ManualPanelScreenState extends State<ManualPanelScreen> {
  PanelTemplate? _selectedTemplate;
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Panel Manually'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Panel Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Panel Name',
                  hintText: 'e.g. Main Panel, Kitchen Sub-Panel',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for the panel';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Panel Location',
                  hintText: 'e.g. Garage, Basement',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the panel location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              Text(
                'Select Panel Template',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              _buildTemplateSelector(),
              SizedBox(height: 24),
              if (_selectedTemplate != null)
                _buildPanelPreview(),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _createPanel,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    child: Text('Create Panel'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTemplateSelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: PanelTemplates.templates.length,
      itemBuilder: (context, index) {
        final template = PanelTemplates.templates[index];
        final isSelected = _selectedTemplate?.name == template.name;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTemplate = template;
            });
          },
          child: Card(
            elevation: isSelected ? 4 : 1,
            color: isSelected ? Colors.blue.shade50 : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.electrical_services,
                    size: 36,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    template.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    template.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPanelPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Panel Preview',
          style: Theme.of(context as BuildContext).textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedTemplate != null
              ? CustomPaint(
                  painter: PanelGridPainter(
                    columns: _selectedTemplate!.columns,
                    rows: _selectedTemplate!.rows,
                  ),
                  child: Container(),
                )
              : Center(
                  child: Text('Select a template to see preview'),
                ),
        ),
      ],
    );
  }
  
  Future<void> _createPanel() async {
    if (_formKey.currentState!.validate() && _selectedTemplate != null) {
      // Generate a panel image
      final imagePath = await _generatePanelImage();
      
      // Create the panel
      final panel = Panel(
        name: _nameController.text,
        imagePath: imagePath,
        location: _locationController.text,
        circuitIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await Provider.of<PanelService>(context as BuildContext, listen: false).addPanel(panel);
      Navigator.of(context as BuildContext).pop();
    }
  }
  
  Future<String> _generatePanelImage() async {
    // This is a simplified version - in a real app, you'd render
    // the panel to an image file
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(
      _selectedTemplate!.columns * 100.0,
      _selectedTemplate!.rows * 30.0,
    );
    
    // Paint the panel background
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Draw the grid
    final gridPainter = PanelGridPainter(
      columns: _selectedTemplate!.columns,
      rows: _selectedTemplate!.rows,
    );
    gridPainter.paint(canvas, size);
    
    // Convert to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    
    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final panelImagesDir = Directory('${directory.path}/PanelImages');
    if (!await panelImagesDir.exists()) {
      await panelImagesDir.create(recursive: true);
    }
    
    final file = File(join(
      panelImagesDir.path,
      'panel_${DateTime.now().millisecondsSinceEpoch}.png',
    ));
    
    await file.writeAsBytes(
      pngBytes!.buffer.asUint8List(pngBytes.offsetInBytes, pngBytes.lengthInBytes),
    );
    
    return file.path;
  }
}

class PanelGridPainter extends CustomPainter {
  final int columns;
  final int rows;
  
  PanelGridPainter({
    required this.columns,
    required this.rows,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;
    
    // Draw vertical lines
    for (int i = 0; i <= columns; i++) {
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (int i = 0; i <= rows; i++) {
      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.width, i * cellHeight),
        paint,
      );
    }
    
    // Draw panel frame
    final framePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      framePaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}