/// Supabase configuration and client access.
///
/// IMPORTANT — Security:
/// • The `publishableKey` (anon key) is safe for client-side use; it
///   only grants access allowed by Row Level Security (RLS) policies.
/// • NEVER embed the `service_role` key in the app.

class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://qmqhdtnvlnuwjbvptuce.supabase.co';
  static const String publishableKey =
      'sb_publishable_TRl8lRt3DpdBHG1_MTKoLg_Gpny4Pf2';
}
