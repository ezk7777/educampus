import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/auth_screen.dart'; // <--- Ajoute cette ligne d'import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EduCampusApp());
}

class EduCampusApp extends StatelessWidget {
  const EduCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduCampus',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthScreen(), // <--- Change ceci pour appeler ton écran
    );
  }
}