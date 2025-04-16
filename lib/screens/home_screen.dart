// screens/home_screen.dart (updated version)
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/panel_service.dart';
import '../models/panel.dart';
import '../screens/panel_capture/panel_capture_screen.dart';
import '../screens/panel_editor/panel_editor_screen.dart';
import '../screens/panel_creation/manual_panel_screen.dart';
import '../screens/energy_monitoring/energy_monitoring_dashboard.dart';
import '../screens/device_mapping/device_mapping_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of main app screens
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _PanelsDashboard(),
      EnergyMonitoringDashboard(),
      _DeviceManagementDashboard(),
      _SettingsDashboard(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.electrical_services),
            label: 'Panels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Energy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Devices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _PanelsDashboard extends StatelessWidget {
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
              return _PanelListItem(
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

class _PanelListItem extends StatelessWidget {
  final Panel panel;
  final VoidCallback onTap;

  const _PanelListItem({
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

class _DeviceManagementDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // TODO: Implement device addition
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Add device functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Device Management Dashboard'),
      ),
    );
  }
}

class _SettingsDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Backup & Restore'),
            subtitle: Text('Create a backup of your electrical panel data'),
            leading: Icon(Icons.backup),
            onTap: () {
              // TODO: Implement backup functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Backup functionality coming soon')),
              );
            },
          ),
          ListTile(
            title: Text('Theme'),
            subtitle: Text('Change app appearance'),
            leading: Icon(Icons.color_lens),
            onTap: () {
              // TODO: Implement theme switching
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Theme settings coming soon')),
              );
            },
          ),
          ListTile(
            title: Text('About'),
            subtitle: Text('App version and information'),
            leading: Icon(Icons.info_outline),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Electrical Panel Mapper',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(Icons.electrical_services),
                children: [
                  Text('Track and manage your electrical panels with ease.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}