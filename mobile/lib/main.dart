import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mobile/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_PUBLIC_KEY'] ?? '',
  );

  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Open boxes for offline storage
  await Hive.openBox<String>('subjects');
  await Hive.openBox<String>('modules');
  await Hive.openBox<String>('quizzes');

  runApp(const MyApp());
}
