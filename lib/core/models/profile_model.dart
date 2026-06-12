class ProfileModel {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final String? healthPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.healthPreferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      pushNotificationsEnabled: json['push_notifications_enabled'] as bool? ?? true,
      emailNotificationsEnabled: json['email_notifications_enabled'] as bool? ?? true,
      healthPreferences: json['health_preferences'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'push_notifications_enabled': pushNotificationsEnabled,
      'email_notifications_enabled': emailNotificationsEnabled,
      'health_preferences': healthPreferences,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
