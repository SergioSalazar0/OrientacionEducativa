import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://bdukzqnvvnsspmyqegxp.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkdWt6cW52dm5zc3BteXFlZ3hwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2NDkzMzksImV4cCI6MjA5MjIyNTMzOX0.YyZjHb5-hJ2rQ8COSbhcjavNvrL9oC-9VSuEGPjKfc8';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}

