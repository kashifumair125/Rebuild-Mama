// TODO: Implement Exercise model
// This model represents an individual exercise

class Exercise {
  final String id;
  final String name;
  final String description;
  final int level;
  final int durationSeconds;
  final int? sets;
  final int? reps;
  final String animationPath;
  final List<String> modifications;
  final List<String> safetyTips;
  final DateTime createdAt;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.durationSeconds,
    this.sets,
    this.reps,
    required this.animationPath,
    required this.modifications,
    required this.safetyTips,
    required this.createdAt,
  });

  // TODO: Add fromJson and toJson methods
  // TODO: Add copyWith method
}
