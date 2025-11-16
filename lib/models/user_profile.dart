// TODO: Implement UserProfile model
// This model represents user profile information

enum DeliveryType { vaginal, csection }

class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final DeliveryType deliveryType;
  final DateTime deliveryDate;
  final int weeksPostpartum;
  final int currentLevel;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    required this.deliveryType,
    required this.deliveryDate,
    required this.weeksPostpartum,
    required this.currentLevel,
    required this.createdAt,
    this.updatedAt,
  });

  // TODO: Add fromJson and toJson methods
  // TODO: Add copyWith method
  // TODO: Calculate weeks postpartum from delivery date
}
