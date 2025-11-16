// TODO: Implement ProgressData model
// This model tracks user progress metrics

class ProgressData {
  final String id;
  final String userId;
  final DateTime date;
  final double? diastasisRectiGap; // in finger widths
  final int? pelvicFloorStrength; // 1-10 scale
  final double? weight; // in kg
  final String? photoPath; // local file path
  final int workoutCompletionCount;
  final DateTime createdAt;

  ProgressData({
    required this.id,
    required this.userId,
    required this.date,
    this.diastasisRectiGap,
    this.pelvicFloorStrength,
    this.weight,
    this.photoPath,
    required this.workoutCompletionCount,
    required this.createdAt,
  });

  // TODO: Add fromJson and toJson methods
  // TODO: Add copyWith method
  // TODO: Calculate BMI if height is available
}
