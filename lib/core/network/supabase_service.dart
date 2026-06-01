import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/env_config.dart';
import 'package:logger/logger.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final _logger = Logger();
  late final SupabaseClient client;

  Future<void> init() async {
    try {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
      );
      client = Supabase.instance.client;
      _logger.i('Supabase initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Supabase: $e');
      rethrow;
    }
  }
}
