class Constants {
  Constants._();
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supbasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const String supbaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
}
