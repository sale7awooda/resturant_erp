// import 'package:supabase_flutter/supabase_flutter.dart';

// class SupabaseConfig {
//   static Future<void> initialize() async {
//     await Supabase.initialize(
//       url: 'https://your-project.supabase.co',
//       anonKey: 'your-anon-key',
//     );
//   }

//   static SupabaseClient get client => Supabase.instance.client;
// }
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://xwkwgkwcxigpekdwtvxz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh3a3dna3djeGlncGVrZHd0dnh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2NTUzMTIsImV4cCI6MjA2NTIzMTMxMn0.mUg0Gg4v8u4AopXnreg5wDhsm9mfXlgZy6NaLyNgKJY',
  );
}

final supabase = Supabase.instance.client;
