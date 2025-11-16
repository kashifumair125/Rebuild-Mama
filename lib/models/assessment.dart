// TODO: Implement Assessment model
// This model represents assessment questionnaires

enum AssessmentType { pelvicFloor, diastasisRecti, symptom }

class Assessment {
  final String id;
  final String userId;
  final AssessmentType type;
  final Map<String, dynamic> responses;
  final int score;
  final String classification; // e.g., "Weak", "Moderate", "Strong"
  final DateTime completedAt;

  Assessment({
    required this.id,
    required this.userId,
    required this.type,
    required this.responses,
    required this.score,
    required this.classification,
    required this.completedAt,
  });

  // TODO: Add fromJson and toJson methods
  // TODO: Add copyWith method
  // TODO: Add scoring logic for different assessment types
}
