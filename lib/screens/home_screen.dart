import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/panel_service.dart';
import '../models/panel.dart';
import 'panel_capture/panel_capture_screen.dart';
import 'panel_editor/panel_editor_screen.dart';
import 'panel_creation/manual_panel_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Electrical Panel Mapper'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Search coming soon')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settings coming soon')),
              );
            },
          ),
        ],
      ),
      body: Consumer<PanelService>(
        builder: (context, panelService, child) {
          final panels = panelService.panels;
          
          if (panels.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.electrical_services,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No electrical panels added yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Add a panel by taking a photo or creating one manually',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _navigateToPanelCapture(context),
                        icon: Icon(Icons.camera_alt),
                        label: Text('Add Panel\nfrom Photo'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(16),
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToManualPanelCreation(context),
                        icon: Icon(Icons.edit),
                        label: Text('Create Panel\nManually'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: panels.length,
            itemBuilder: (context, index) {
              final panel = panels[index];
              return PanelListItem(
                panel: panel,
                onTap: () => _navigateToPanelEditor(context, panel),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _navigateToManualPanelCreation(context),
            tooltip: 'Create Panel Manually',
            heroTag: 'createManually',
            child: Icon(Icons.edit),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => _navigateToPanelCapture(context),
            tooltip: 'Add Panel from Photo',
            heroTag: 'addFromPhoto',
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }

  void _navigateToPanelCapture(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PanelCaptureScreen(),
      ),
    );
  }

  void _navigateToPanelEditor(BuildContext context, Panel panel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PanelEditorScreen(panel: panel),
      ),
    );
  }
  
  void _navigateToManualPanelCreation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManualPanelScreen(),
      ),
    );
  }
}

class PanelListItem extends StatelessWidget {
  final Panel panel;
  final VoidCallback onTap;

  const PanelListItem({
    super.key,
    required this.panel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel image preview
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(panel.imagePath),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.electrical_services,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
            // Panel info
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          panel.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Consumer<PanelService>(
                        builder: (context, panelService, child) {
                          final circuitCount = panelService
                              .getCircuitsForPanel(panel.id!)
                              .length;
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '$circuitCount circuits',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 4),
                      Text(
                        panel.location,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Created ${_formatDate(panel.createdAt)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}