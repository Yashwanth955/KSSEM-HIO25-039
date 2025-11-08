import 'package:supabase_flutter/supabase_flutter.dart';

class Supa {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://YOUR-PROJECT-REF.supabase.co',
      anonKey: 'YOUR-ANON-KEY',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
