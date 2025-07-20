import 'package:flutter/material.dart';
import 'package:projet_sante/pages/DisAccueilPage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _continueToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Disaccueilpage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo ou Illustration
                Container(
                  height: 70,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.health_and_safety,
                      color: Colors.green.shade800, size: 60),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Bienvenue sur Kenechat 👩‍⚕️",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Username Field
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Numero de téléphone",
                    prefixIcon: Icon(Icons.person, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    prefixIcon: Icon(Icons.lock, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _continueToHome,
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text(
                      "Connexion",
                      style: TextStyle(fontSize: 18,color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                      shadowColor: Colors.greenAccent.shade100,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Optional: Mot de passe oublié
                TextButton(
                  onPressed: () {
                    // Naviguer vers une page de récupération si nécessaire
                  },
                  child: const Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
