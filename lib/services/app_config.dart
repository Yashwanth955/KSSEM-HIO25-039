// lib/services/app_config.dart
// Central place to manage environment-specific settings.

class AppConfig {
  // Point this to your backend base URL.
  // For Android emulator, use 'http://10.0.2.2:4000'
  // For physical device on LAN, use your PC IP, e.g. 'http://192.168.1.23:4000'
  static const String backendBaseUrl = 'http://localhost:4000';

  // If your backend requires auth, put a token here or build a proper auth flow.
  static const String? authToken = null;

  // Supabase configuration (anon key only, never ship service role key)
  static const String supabaseUrl = 'https://ljqdotxtfwfllyzvlslk.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxqcWRvdHh0ZndmbGx5enZsc2xrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1NDkyMjUsImV4cCI6MjA3ODEyNTIyNX0.Zdq-clvwEakn_ZUAsiFuHlV7uhxtzUbgHJDzEL_ru04';

  // Feature flag to switch between Node backend and Supabase for report storage
  static const bool useSupabase = true;
}
