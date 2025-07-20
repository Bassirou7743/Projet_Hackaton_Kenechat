import 'package:flutter/material.dart';
import 'package:projet_sante/pages/Discussion2.dart';
import 'package:projet_sante/pages/Ecrire.dart';


class Disaccueilpage extends StatelessWidget {
  const Disaccueilpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.health_and_safety, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Assistant Médical",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const Text(
                  "Comment souhaitez-vous poser votre question ?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),

                // Bouton "Discussion vocale"
                _buildOptionCard(
                  context,
                  icon: Icons.mic,
                  label: "Discussion vocale",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VoiceAssistant()),
                  ),
                ),

                const SizedBox(height: 50),

                // Bouton "Écrire une question"
                _buildOptionCard(
                  context,
                  icon: Icons.edit_note,
                  label: "Écrire une question",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EcrirePage()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.green[600],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade100,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
