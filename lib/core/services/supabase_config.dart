/// Supabase connection configuration.
///
/// IMPORTANT: Replace the placeholder values below with your real Supabase
/// project URL and anon key before running the app.
///
/// You can get these from your Supabase dashboard:
///   Settings → API → Project URL & anon key
///
/// For production, load these from environment variables
/// (e.g. flutter_dotenv) or a config service.
class SupabaseConfig {
  SupabaseConfig._();

  /// The URL of your Supabase project (e.g. https://xxxxx.supabase.co)
  static const String supabaseUrl = 'https://zbivdjbibtnvtcdrstpb.supabase.co';

  /// The anon/public API key – safe to include in client code.
  /// NOTE: the Supabase SDK now calls this parameter `publishableKey`.
  static const String supabasePublishableKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpiaXZkamJpYnRudnRjZHJzdHBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExMTI1NTIsImV4cCI6MjA5NjY4ODU1Mn0.RKO3acYNR8JbgIKCsZtTOITdYgKBpbf2kE4SUiEX7w0';
}
