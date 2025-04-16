import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/camera_service.dart';
import '../../services/panel_service.dart';
import '../../models/panel.dart';
import 'package:image_picker/image_picker.dart';

class PanelCaptureScreen extends StatefulWidget {
  const PanelCaptureScreen({super.key});

  @override
  PanelCaptureScreenState createState() => PanelCaptureScreenState();
}

class PanelCaptureScreenState extends State<PanelCaptureScreen> {
  final CameraService _cameraService = CameraService();
  final ImagePicker _imagePicker = ImagePicker();
  String? _imagePath;
  bool _isInitialized = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initializeCamera();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize camera: $e')),
      );
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      final imagePath = await _cameraService.takePicture();
      setState(() {
        _imagePath = imagePath;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _savePanel() async {
    if (_formKey.currentState!.validate() && _imagePath != null) {
      final panel = Panel(
        name: _nameController.text,
        imagePath: _imagePath!,
        location: _locationController.text,
        circuitIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await Provider.of<PanelService>(context, listen: false).addPanel(panel);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Electrical Panel'),
      ),
      body: _imagePath == null
          ? _buildCameraView()
          : _buildPanelDetailsForm(),
    );
  }

  Widget _buildCameraView() {
    if (!_isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            child: CameraPreview(_cameraService.controller!),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.photo_library),
                label: Text('Gallery'),
              ),
              FloatingActionButton(
                onPressed: _takePicture,
                child: Icon(Icons.camera_alt),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPanelDetailsForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panel Image',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(File(_imagePath!)),
                  fit: BoxFit.cover,
                ),
              ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _imagePath = null;
                    });
                  },
                  child: Text('Retake Photo'),
                ),
                ElevatedButton(
                  onPressed: _savePanel,
                  child: Text('Save Panel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// For this example, we're using a placeholder for CameraPreview
class CameraPreview extends StatelessWidget {
  final CameraController controller;

  const CameraPreview(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: controller.buildPreview(),
    );
  }
}