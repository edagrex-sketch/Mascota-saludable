/// Data model representing a vaccine record for a pet.
class VaccineModel {
  final String id;
  final String petId;
  final String name;
  final DateTime applicationDate;
  final DateTime? nextDoseDate;
  final String? veterinarian;
  final String? clinic;
  final String? batchNumber;
  final String? certificateUrl;
  final String status; // 'completed' | 'pending' | 'overdue'
  final String? notes;
  final DateTime createdAt;

  const VaccineModel({
    required this.id,
    required this.petId,
    required this.name,
    required this.applicationDate,
    this.nextDoseDate,
    this.veterinarian,
    this.clinic,
    this.batchNumber,
    this.certificateUrl,
    this.status = 'pending',
    this.notes,
    required this.createdAt,
  });

  factory VaccineModel.fromMap(Map<String, dynamic> map) {
    return VaccineModel(
      id: map['id'] as String? ?? '',
      petId: map['pet_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      applicationDate:
          DateTime.tryParse(map['application_date'] as String? ?? '') ??
              DateTime.now(),
      nextDoseDate:
          DateTime.tryParse(map['next_dose_date'] as String? ?? ''),
      veterinarian: map['veterinarian'] as String?,
      clinic: map['clinic'] as String?,
      batchNumber: map['batch_number'] as String?,
      certificateUrl: map['certificate_url'] as String?,
      status: map['status'] as String? ?? 'pending',
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'name': name,
      'application_date': applicationDate.toIso8601String().split('T')[0],
      'next_dose_date': nextDoseDate?.toIso8601String().split('T')[0],
      'veterinarian': veterinarian,
      'clinic': clinic,
      'batch_number': batchNumber,
      'certificate_url': certificateUrl,
      'status': status,
      'notes': notes,
    };
  }

  VaccineModel copyWith({
    String? id,
    String? petId,
    String? name,
    DateTime? applicationDate,
    DateTime? nextDoseDate,
    String? veterinarian,
    String? clinic,
    String? batchNumber,
    String? certificateUrl,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return VaccineModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      applicationDate: applicationDate ?? this.applicationDate,
      nextDoseDate: nextDoseDate ?? this.nextDoseDate,
      veterinarian: veterinarian ?? this.veterinarian,
      clinic: clinic ?? this.clinic,
      batchNumber: batchNumber ?? this.batchNumber,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Human-readable status label.
  String get statusLabel {
    switch (status) {
      case 'completed':
        return 'Completada';
      case 'pending':
        return 'Pendiente';
      case 'overdue':
        return 'Vencida';
      default:
        return 'Desconocido';
    }
  }

  /// Whether the vaccine is overdue.
  bool get isOverdue =>
      status == 'pending' && nextDoseDate != null && nextDoseDate!.isBefore(DateTime.now());

  /// Days until next dose (negative if overdue).
  int get daysUntilNextDose {
    if (nextDoseDate == null) return 0;
    return nextDoseDate!.difference(DateTime.now()).inDays;
  }
}
