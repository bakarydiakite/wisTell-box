import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: Column(
        children: [
          // ... autres éléments du profil
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _profileOption(context, "Vos abonnements", Icons.subscriptions),
                _profileOption(context, "Activité du compte", Icons.history),
                _profileOption(context, "Paramètres", Icons.settings),
                _profileOption(context, "Déconnexion", Icons.logout),
                _profileOption(context, "Connexion", Icons.login), // Option ajoutée
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileOption(BuildContext context, String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (title == "Déconnexion") {
            // Ajouter la logique de déconnexion ici
          } else if (title == "Connexion") {
            Navigator.pushNamed(context, '/login');
          }
        },
      ),
    );
  }
}