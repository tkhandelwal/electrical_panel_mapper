import 'dart:convert';

class Circuit {
  final int? id;
  final int panelId;
  final String label;
  final int amperage;
  final String color;
  final List<int> deviceIds;
  final bool isActive;
  final Map<String, dynamic> metadata;

  Circuit({
    this.id,
    required this.panelId,
    required this.label,
    required this.amperage,
    required this.color,
    this.deviceIds = const [],
    this.isActive = true,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'panelId': panelId,
      'label': label,
      'amperage': amperage,
      'color': color,
      'deviceIds': deviceIds.isEmpty ? '' : deviceIds.join(','),
      'isActive': isActive ? 1 : 0,
      'metadata': metadata.isEmpty ? null : jsonEncode(metadata),
    };
  }

  factory Circuit.fromMap(Map<String, dynamic> map) {
    return Circuit(
      id: map['id'],
      panelId: map['panelId'],
      label: map['label'],
      amperage: map['amperage'],
      color: map['color'],
      deviceIds: map['deviceIds'] != null && map['deviceIds'].toString().isNotEmpty 
          ? map['deviceIds'].toString().split(',')
              .where((e) => e.isNotEmpty)
              .map((e) => int.parse(e)).toList() 
          : [],
      isActive: map['isActive'] == 1,
      metadata: map['metadata'] != null && map['metadata'].toString().isNotEmpty
          ? (map['metadata'] is String 
              ? jsonDecode(map['metadata']) as Map<String, dynamic>
              : map['metadata'] as Map<String, dynamic>)
          : {},
    );
  }

  // Create a copy of this circuit with updated fields
  Circuit copyWith({
    int? id,
    int? panelId,
    String? label,
    int? amperage,
    String? color,
    List<int>? deviceIds,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return Circuit(
      id: id ?? this.id,
      panelId: panelId ?? this.panelId,
      label: label ?? this.label,
      amperage: amperage ?? this.amperage,
      color: color ?? this.color,
      deviceIds: deviceIds ?? this.deviceIds,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods for position metadata
  int? get position => metadata.containsKey('position') ? metadata['position'] as int? : null;
  
  double? get posX => metadata.containsKey('posX') ? metadata['posX'] as double? : null;
  double? get posY => metadata.containsKey('posY') ? metadata['posY'] as double? : null;
  
  // Method to add device to this circuit
  Circuit addDevice(int deviceId) {
    if (deviceIds.contains(deviceId)) return this;
    return copyWith(deviceIds: [...deviceIds, deviceId]);
  }
  
  // Method to remove device from this circuit
  Circuit removeDevice(int deviceId) {
    if (!deviceIds.contains(deviceId)) return this;
    return copyWith(deviceIds: deviceIds.where((id) => id != deviceId).toList());
  }
  
  // Method to set position for manual panel layouts
  Circuit setPosition(int position) {
    final newMetadata = Map<String, dynamic>.from(metadata);
    newMetadata['position'] = position;
    return copyWith(metadata: newMetadata);
  }
  
  // Method to set coordinates for room layout
  Circuit setCoordinates(double x, double y) {
    final newMetadata = Map<String, dynamic>.from(metadata);
    newMetadata['posX'] = x;
    newMetadata['posY'] = y;
    return copyWith(metadata: newMetadata);
  }
  
  @override
  String toString() {
    return 'Circuit{id: $id, label: $label, amperage: $amperage, devices: ${deviceIds.length}}';
  }
}