import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module  // This annotation tells injectable to treat this class as a registering module for external dependencies
abstract class SupabaseModule {  // This (abstract) class is just a wrapper for the Supabase variable; we can't instantiate it
  @lazySingleton  // This tells injectable that the same instance will be used throughout the app
  SupabaseClient get supabaseClient => Supabase.instance.client;
}