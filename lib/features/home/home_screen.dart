import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- Ajoute cet import
import '../auth/auth_service.dart';
import '../auth/auth_screen.dart';
import 'course_detail_screen.dart';

class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("EduCampus"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await _authService.signOut();
            if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
          })
        ],
      ),
      // StreamBuilder écoute ta collection "courses" dans Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(data['title'] ?? 'Sans titre'),
                  subtitle: Text("Progression : ${data['progress'] ?? '0%'}"),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetailScreen(courseTitle: data['title'])));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}