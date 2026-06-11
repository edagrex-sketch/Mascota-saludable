import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import 'auth_service.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  Future<ProfileModel?> getProfile() async {
    final user = _authService.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;

    return ProfileModel.fromJson(response);
  }

  Future<void> updateProfile(ProfileModel profile) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');

    await _supabase
        .from('profiles')
        .upsert(profile.toJson());
  }
}
