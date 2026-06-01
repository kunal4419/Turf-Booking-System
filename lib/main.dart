import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:turf_system/app.dart';
import 'package:turf_system/core/network/supabase_service.dart';
import 'package:turf_system/services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await SupabaseService().init();
  await LocalStorageService().init();

  runApp(const MyApp());
}