import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../courses/domain/course.dart';
import '../auth/data/auth_repository.dart';

class CertificateScreen extends ConsumerStatefulWidget {
  final Course course;

  const CertificateScreen({super.key, required this.course});

  @override
  ConsumerState<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends ConsumerState<CertificateScreen> {
  bool _isDownloading = false;
  bool _isSharing = false;

  String _getUserDisplayName(User? user) {
    if (user == null) return "Apprenant";
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    if (user.email != null && user.email!.isNotEmpty) {
      final namePart = user.email!.split('@').first;
      return namePart.substring(0, 1).toUpperCase() + namePart.substring(1);
    }
    return "Apprenant";
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      "janvier", "février", "mars", "avril", "mai", "juin",
      "juillet", "août", "septembre", "octobre", "novembre", "décembre"
    ];
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }

  void _simulateDownload() {
    setState(() {
      _isDownloading = true;
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text("Certificat enregistré dans vos téléchargements !"),
              ],
            ),
            backgroundColor: const Color(0xFF10B981), // Emerald
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }

  void _simulateShare() {
    setState(() {
      _isSharing = true;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.link_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text("Lien de partage copié dans le presse-papiers !"),
              ],
            ),
            backgroundColor: const Color(0xFF4F46E5), // Indigo
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authRepositoryProvider).currentUser;
    final studentName = _getUserDisplayName(currentUser);
    final completionDate = _getFormattedDate();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Mon Certificat",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Certificate Container (Diploma Style)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7), // Creamy vintage white
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD97706), // Gold/Amber border
                    width: 6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Certificate Top Icon/Seal
                        const Icon(
                          Icons.workspace_premium_rounded,
                          size: 60,
                          color: Color(0xFFD97706), // Gold color
                        ),
                        const SizedBox(height: 16),
                        
                        // Header
                        const Text(
                          "CERTIFICAT DE RÉUSSITE",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 80,
                          height: 1.5,
                          color: const Color(0xFFD97706),
                        ),
                        const SizedBox(height: 20),
                        
                        const Text(
                          "Ce document officiel est décerné avec fierté à",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Student Name
                        Text(
                          studentName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4F46E5), // Indigo
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        const Text(
                          "pour avoir complété avec succès et validé l'évaluation du cours",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Course Name
                        Text(
                          widget.course.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Completion Date
                        Text(
                          "Obtenu avec succès le $completionDate",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Divider and Signature block
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  "EduCampus",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'serif',
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 140,
                                  height: 1,
                                  color: const Color(0xFFCBD5E1),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "La Direction EduCampus",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Action Buttons
              if (_isDownloading)
                const CircularProgressIndicator(color: Color(0xFF4F46E5))
              else if (_isSharing)
                const CircularProgressIndicator(color: Color(0xFF4F46E5))
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _simulateDownload,
                        icon: const Icon(Icons.file_download_rounded, color: Colors.white),
                        label: const Text(
                          "Télécharger le certificat",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5), // Indigo
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _simulateShare,
                        icon: const Icon(Icons.share_rounded, color: Color(0xFF4F46E5)),
                        label: const Text(
                          "Partager le certificat",
                          style: TextStyle(color: Color(0xFF4F46E5), fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
