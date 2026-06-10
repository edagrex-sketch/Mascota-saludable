/// Data model representing a pet registered by the user.
class PetModel {
  final String id;
  final String userId;
  final String name;
  final String breed;
  final int ageYears;
  final double weightKg;
  final String? photoUrl;
  final String status; // 'healthy' | 'attention' | 'critical'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PetModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.breed,
    this.ageYears = 0,
    this.weightKg = 0,
    this.photoUrl,
    this.status = 'healthy',
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PetModel.fromMap(Map<String, dynamic> map) {
    return PetModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      breed: map['breed'] as String? ?? '',
      ageYears: map['age_years'] as int? ?? 0,
      weightKg: (map['weight_kg'] as num?)?.toDouble() ?? 0.0,
      photoUrl: map['photo_url'] as String?,
      status: map['status'] as String? ?? 'healthy',
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'breed': breed,
      'age_years': ageYears,
      'weight_kg': weightKg,
      'photo_url': photoUrl,
      'status': status,
      'notes': notes,
    };
  }

  PetModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? breed,
    int? ageYears,
    double? weightKg,
    String? photoUrl,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      ageYears: ageYears ?? this.ageYears,
      weightKg: weightKg ?? this.weightKg,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Computed health progress (0.0–1.0) based on status.
  double get healthProgress {
    switch (status) {
      case 'healthy':
        return 0.85;
      case 'attention':
        return 0.45;
      case 'critical':
        return 0.15;
      default:
        return 0.5;
    }
  }

  /// Whether the pet needs attention.
  bool get needsAttention => status != 'healthy';

  /// Human-readable status label.
  String get statusLabel {
    switch (status) {
      case 'healthy':
        return 'Saludable';
      case 'attention':
        return 'Revisión pendiente';
      case 'critical':
        return 'Atención urgente';
      default:
        return 'Desconocido';
    }
  }
}
