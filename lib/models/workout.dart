// TODO: Implement Workout model
// This model represents a workout session with exercises

class Workout {
  final String id;
  final String name;
  final String description;
  final int level; // 1, 2, or 3
  final int durationMinutes;
  final List<String> exerciseIds;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.durationMinutes,
    required this.exerciseIds,
    required this.createdAt,
    this.updatedAt,
  });

  // TODO: Add fromJson and toJson methods
  // TODO: Add copyWith method
  // TODO: Add Drift table annotations if needed
}
