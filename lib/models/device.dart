enum DeviceType {
  outlet,
  switch_,
  light,
  appliance,
  other,
}

class Device {
  final int? id;
  final int roomId;
  final int circuitId;
  final DeviceType type;
  final double posX; // X position on floor plan
  final double posY; // Y position on floor plan
  final String label;
  
  Device({
    this.id,
    required this.roomId,
    required this.circuitId,
    required this.type,
    required this.posX,
    required this.posY,
    required this.label,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'circuitId': circuitId,
      'type': type.toString().split('.').last,
      'posX': posX,
      'posY': posY,
      'label': label,
    };
  }
  
  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'],
      roomId: map['roomId'],
      circuitId: map['circuitId'],
      type: DeviceType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => DeviceType.other,
      ),
      posX: map['posX'],
      posY: map['posY'],
      label: map['label'],
    );
  }
}