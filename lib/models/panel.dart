class Panel {
  final int? id;
  final String name;
  final String imagePath;
  final String location;
  final List<int> circuitIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Panel({
    this.id,
    required this.name,
    required this.imagePath,
    required this.location,
    required this.circuitIds,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'location': location,
      'circuitIds': circuitIds.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Panel.fromMap(Map<String, dynamic> map) {
    return Panel(
      id: map['id'],
      name: map['name'],
      imagePath: map['imagePath'],
      location: map['location'],
      circuitIds: map['circuitIds'] != null && map['circuitIds'].toString().isNotEmpty
          ? map['circuitIds'].toString().split(',')
              .where((e) => e.isNotEmpty)
              .map((e) => int.parse(e)).toList()
          : [],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}