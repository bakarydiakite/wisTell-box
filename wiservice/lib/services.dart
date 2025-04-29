import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Services")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _serviceCard(
            context,
            Icons.phone,
            'Appels internationaux',
            'Appelez partout dans le monde à bas prix',
          ),
          _serviceCard(
            context,
            Icons.message,
            'Envoyer des SMS à vos proches',
            'Appelez partout dans le monde à bas prix',
          ),
          _serviceCard(
            context,
            Icons.phone,
            'Appels internationaux',
            'Appelez partout dans le monde à bas prix',
          ),
          _serviceCard(
            context,
            Icons.phone,
            'Appels internationaux',
            'Appelez partout dans le monde à bas prix',
          ),
          // ... autres cartes de service
        ],
      ),
    );
  }

  Widget _serviceCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}