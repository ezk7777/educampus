import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../home/home_screen.dart'; // Import important

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final user = await _authService.signIn(_emailController.text.trim(), _passwordController.text.trim());
    setState(() => _isLoading = false);

    if (user != null && mounted) {
      // Redirection vers HomeScreen après succès
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur de connexion")));
    }
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    final user = await _authService.signUp(_emailController.text.trim(), _passwordController.text.trim());
    setState(() => _isLoading = false);

    if (user != null && mounted) {
      // Redirection vers HomeScreen après succès
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de l'inscription")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("EduCampus", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 20),
                  TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())),
                  const SizedBox(height: 15),
                  TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Mot de passe", border: OutlineInputBorder()), obscureText: true),
                  const SizedBox(height: 20),
                  if (_isLoading) 
                    const CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _submit, child: const Text("Se connecter"))),
                        const SizedBox(height: 10),
                        TextButton(onPressed: _register, child: const Text("Créer un compte")),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}