class RhythmEntry {
  const RhythmEntry({
    required this.id,
    required this.createdAt,
    required this.energy,
    required this.emotions,
    required this.activities,
    required this.note,
    this.isSample = false,
  });

  final String id;
  final DateTime createdAt;
  final int energy;
  final List<String> emotions;
  final List<String> activities;
  final String note;
  final bool isSample;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'energy': energy,
    'emotions': emotions,
    'activities': activities,
    'note': note,
    'isSample': isSample,
  };

  factory RhythmEntry.fromJson(Map<String, dynamic> json) {
    return RhythmEntry(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      energy: json['energy'] as int,
      emotions: List<String>.from(json['emotions'] as List),
      activities: List<String>.from(json['activities'] as List),
      note: json['note'] as String? ?? '',
      isSample: json['isSample'] as bool? ?? false,
    );
  }

  RhythmEntry copyWith({
    String? id,
    DateTime? createdAt,
    int? energy,
    List<String>? emotions,
    List<String>? activities,
    String? note,
    bool? isSample,
  }) {
    return RhythmEntry(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      energy: energy ?? this.energy,
      emotions: emotions ?? this.emotions,
      activities: activities ?? this.activities,
      note: note ?? this.note,
      isSample: isSample ?? this.isSample,
    );
  }
}
