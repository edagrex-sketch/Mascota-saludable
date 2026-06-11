/// Data model representing a veterinary visit.
class MedicalVisitModel {
  final String id;
  final String petId;
  final DateTime visitDate;
  final String reason;
  final String? diagnosis;
  final String veterinarian;
  final String? clinic;
  final String? notes;
  final DateTime createdAt;

  const MedicalVisitModel({
    required this.id,
    required this.petId,
    required this.visitDate,
    required this.reason,
    this.diagnosis,
    required this.veterinarian,
    this.clinic,
    this.notes,
    required this.createdAt,
  });

  factory MedicalVisitModel.fromMap(Map<String, dynamic> map) {
    return MedicalVisitModel(
      id: map['id'] as String? ?? '',
      petId: map['pet_id'] as String? ?? '',
      visitDate: DateTime.tryParse(map['visit_date'] as String? ?? '') ??
          DateTime.now(),
      reason: map['reason'] as String? ?? '',
      diagnosis: map['diagnosis'] as String?,
      veterinarian: map['veterinarian'] as String? ?? '',
      clinic: map['clinic'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'visit_date': visitDate.toIso8601String().split('T')[0],
      'reason': reason,
      'diagnosis': diagnosis,
      'veterinarian': veterinarian,
      'clinic': clinic,
      'notes': notes,
    };
  }
}
