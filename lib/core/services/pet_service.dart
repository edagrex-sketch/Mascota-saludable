import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet_model.dart';

/// Service handling all pet CRUD operations against Supabase.
class PetService {
  PetService._();
  static final PetService _instance = PetService._();
  factory PetService() => _instance;

  final _client = Supabase.instance.client;
  static const _table = 'pets';

  /// Fetch all pets for the current user.
  Future<List<PetModel>> getPets() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return _parseList(response);
  }

  /// Fetch a single pet by ID.
  Future<PetModel> getPet(String id) async {
    final response = await _client.from(_table).select().eq('id', id).single();
    return PetModel.fromMap(response);
  }

  /// Create a new pet record.
  Future<PetModel> createPet(PetModel pet) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    final response = await _client.from(_table).insert({
      'id': pet.id,
      'user_id': userId,
      'name': pet.name,
      'breed': pet.breed,
      'age_years': pet.ageYears,
      'weight_kg': pet.weightKg,
      'photo_url': pet.photoUrl,
      'status': pet.status,
      'notes': pet.notes,
    }).select().single();

    return PetModel.fromMap(response);
  }

  /// Update an existing pet record.
  Future<PetModel> updatePet(PetModel pet) async {
    final response = await _client
        .from(_table)
        .update(pet.toMap())
        .eq('id', pet.id)
        .select()
        .single();

    return PetModel.fromMap(response);
  }

  /// Delete a pet record by ID.
  Future<void> deletePet(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  /// Get the count of pets for the current user.
  Future<int> getPetCount() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _client
        .from(_table)
        .select('id')
        .eq('user_id', userId);

    final list = response as List;
    return list.length;
  }

  /// Parse Supabase response into a list of PetModel.
  List<PetModel> _parseList(dynamic response) {
    return (response as List)
        .map((data) => PetModel.fromMap(data as Map<String, dynamic>))
        .toList();
  }
}
