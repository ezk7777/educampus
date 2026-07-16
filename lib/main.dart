import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Généré par flutterfire

void main() async {
  // Indispensable pour Flutter avant d'appeler du code natif
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de Firebase
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
      home: const Scaffold(
        body: Center(child: Text("Bienvenue sur EduCampus !")),
      ),
    );
  }
}