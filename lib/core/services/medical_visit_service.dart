import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medical_visit_model.dart';

/// Service handling CRUD operations for veterinary medical visits.
class MedicalVisitService {
  MedicalVisitService._();
  static final MedicalVisitService _instance = MedicalVisitService._();
  factory MedicalVisitService() => _instance;

  final _client = Supabase.instance.client;
  static const _table = 'medical_visits';

  /// Fetch all visits for a specific pet.
  Future<List<MedicalVisitModel>> getVisits(String petId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('pet_id', petId)
        .order('visit_date', ascending: false);

    return _parseList(response);
  }

  /// Create a new medical visit record.
  Future<MedicalVisitModel> createVisit(MedicalVisitModel visit) async {
    final response = await _client
        .from(_table)
        .insert(visit.toMap())
        .select()
        .single();
    return MedicalVisitModel.fromMap(response);
  }

  /// Parse Supabase response into a list of MedicalVisitModel.
  List<MedicalVisitModel> _parseList(dynamic response) {
    return (response as List)
        .map((data) => MedicalVisitModel.fromMap(data as Map<String, dynamic>))
        .toList();
  }

  /// Check if the medical_visits table exists and has data.
  Future<bool> hasTable() async {
    try {
      await _client.from(_table).select('id').limit(1);
      return true;
    } catch (_) {
      return false;
    }
  }
}
