// models/panel_template.dart
class PanelTemplate {
  final String name;
  final String description;
  final int columns;
  final int rows;
  final List<int> availableAmperages;
  
  const PanelTemplate({
    required this.name,
    required this.description,
    required this.columns,
    required this.rows,
    required this.availableAmperages,
  });
}

// Common panel templates
class PanelTemplates {
  static const List<PanelTemplate> templates = [
    PanelTemplate(
      name: 'Residential Single Phase',
      description: '200A, 40-space panel',
      columns: 2,
      rows: 20,
      availableAmperages: [15, 20, 30, 40, 50, 60, 100],
    ),
    PanelTemplate(
      name: 'Small Residential',
      description: '100A, 20-space panel',
      columns: 2,
      rows: 10,
      availableAmperages: [15, 20, 30, 40, 50],
    ),
    PanelTemplate(
      name: 'Commercial Three Phase',
      description: '225A, 42-space panel',
      columns: 3,
      rows: 14,
      availableAmperages: [15, 20, 30, 40, 50, 60, 70, 100],
    ),
    PanelTemplate(
      name: 'Custom Panel',
      description: 'Create a custom panel layout',
      columns: 2,
      rows: 12,
      availableAmperages: [15, 20, 30, 40, 50, 60, 70, 100],
    ),
  ];
}