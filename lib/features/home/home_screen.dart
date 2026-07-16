import 'package:flutter/material.dart';
import 'course_detail_screen.dart'; // Import indispensable pour la navigation

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Tes 5 cours
  final List<String> courses = const [
    "Introduction à la Programmation",
    "Développement Web avec Vue.js",
    "Architecture des Bases de données",
    "Sécurité Informatique",
    "Projet Hackathon : Décarbonisation",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes Cours - EduCampus")),
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: const Icon(Icons.book, color: Colors.blue),
              title: Text(courses[index]),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigation vers la page de détails avec le titre du cours
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailScreen(
                      courseTitle: courses[index],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}