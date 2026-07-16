import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import nécessaire pour vider les boxes
import 'firebase_options.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/courses/data/local/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialisation de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 2. Initialisation de Hive (gère automatiquement le Web et le Mobile)
  await HiveService.init();

  // ⚠️ LIGNES TEMPORAIRES : À supprimer après votre premier chargement réussi !
  // Ces lignes forcent le nettoyage de votre ancien cache pour injecter les nouveaux cours rédigés.
  try {
    await Hive.box<Map<dynamic, dynamic>>(HiveService.coursesBoxName).clear();
    await Hive.box<Map<dynamic, dynamic>>(HiveService.progressBoxName).clear();
    debugPrint("🧹 Ancien cache Hive vidé avec succès !");
  } catch (e) {
    debugPrint("Erreur lors du nettoyage du cache Hive : $e");
  }

  runApp(const ProviderScope(child: EduCampusApp()));
}

class EduCampusApp extends StatelessWidget {
  const EduCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduCampus',
      debugShowCheckedModeBanner: false, // Retire la bannière rouge "DEBUG" en haut à droite
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,    // Utilise Indigo comme couleur de base pour un look pro
        useMaterial3: true,               // Active les composants modernes Material 3
        brightness: Brightness.light,
      ),
      home: const AuthScreen(),
    );
  }
}