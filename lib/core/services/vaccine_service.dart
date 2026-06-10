import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vaccine_model.dart';

/// Service handling all vaccine CRUD operations against Supabase.
class VaccineService {
  VaccineService._();
  static final VaccineService _instance = VaccineService._();
  factory VaccineService() => _instance;

  final _client = Supabase.instance.client;
  static const _table = 'vaccines';

  /// Fetch all vaccines for a specific pet.
  Future<List<VaccineModel>> getVaccines(String petId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('pet_id', petId)
        .order('application_date', ascending: false);

    return _parseList(response);
  }

  /// Fetch a single vaccine by ID.
  Future<VaccineModel> getVaccine(String id) async {
    final response = await _client.from(_table).select().eq('id', id).single();
    return VaccineModel.fromMap(response);
  }

  /// Create a new vaccine record.
  Future<VaccineModel> createVaccine(VaccineModel vaccine) async {
    final response =
        await _client.from(_table).insert(vaccine.toMap()).select().single();
    return VaccineModel.fromMap(response);
  }

  /// Update an existing vaccine record.
  Future<VaccineModel> updateVaccine(VaccineModel vaccine) async {
    final response = await _client
        .from(_table)
        .update(vaccine.toMap())
        .eq('id', vaccine.id)
        .select()
        .single();

    return VaccineModel.fromMap(response);
  }

  /// Delete a vaccine record by ID.
  Future<void> deleteVaccine(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  /// Fetch all upcoming (pending/overdue) vaccines for a pet.
  Future<List<VaccineModel>> getUpcomingVaccines(String petId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('pet_id', petId)
        .neq('status', 'completed')
        .order('application_date', ascending: true);

    return _parseList(response);
  }

  /// Fetch only completed vaccines for a pet.
  Future<List<VaccineModel>> getCompletedVaccines(String petId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('pet_id', petId)
        .eq('status', 'completed')
        .order('application_date', ascending: false);

    return _parseList(response);
  }

  /// Parse Supabase response into a list of VaccineModel.
  List<VaccineModel> _parseList(dynamic response) {
    return (response as List)
        .map((data) => VaccineModel.fromMap(data as Map<String, dynamic>))
        .toList();
  }
}
