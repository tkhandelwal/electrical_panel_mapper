class Room {
  final int? id;
  final String name;
  final String floorPlan; // Path to floor plan image
  final List<int> deviceIds;
  
  Room({
    this.id,
    required this.name,
    required this.floorPlan,
    this.deviceIds = const [],
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'floorPlan': floorPlan,
      'deviceIds': deviceIds.join(','),
    };
  }
  
  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'],
      name: map['name'],
      floorPlan: map['floorPlan'],
      deviceIds: map['deviceIds']?.toString().split(',')
          .where((e) => e.isNotEmpty)
          .map((e) => int.parse(e)).toList() ?? [],
    );
  }
}