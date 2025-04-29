import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart';

class DialerPage extends StatefulWidget {
  const DialerPage({super.key});

  @override
  State<DialerPage> createState() => _DialerPageState();
}

class _DialerPageState extends State<DialerPage> {
  String number = '';
  final String userPhone = '+224625617377'; // À rendre dynamique plus tard
  final String apiUrl = 'http://192.168.34.227:8000/api/auth/appels/'; // Ajuste bien ici !

  void addDigit(String digit) {
    setState(() {
      number += digit;
    });
  }

  void deleteLast() {
    setState(() {
      if (number.isNotEmpty) {
        number = number.substring(0, number.length - 1);
      }
    });
  }

  Future<void> callNumber() async {
    if (number.isEmpty) return;

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'phone': userPhone,
        'numero': number,
        'type': 'OUT',
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📞 Appel enregistré avec succès')),
      );
      setState(() => number = '');
    } else {
      print("❌ Erreur : ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur d\'enregistrement d\'appel')),
      );
    }
  }

  Future<void> saveContact(BuildContext context, String number) async {
    if (number.isEmpty) return; // Si aucun numéro, on ne fait rien

    final newContact = Contact()
      ..phones = [Phone(number)]
      ..name.first = 'Contact'; // Nom par défaut

    try {
      await FlutterContacts.insertContact(newContact); // juste await sans bool

      // Si ça passe sans erreur :
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📇 Contact enregistré !')),
      );
    } catch (e) {
      print('Erreur lors de l\'insertion : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Échec de l\'enregistrement')),
      );
    }
  }

  Future<void> openContacts() async {
    if (!await FlutterContacts.requestPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission refusée 📵')),
      );
      return;
    }

    final contacts = await FlutterContacts.getContacts(withProperties: true);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactsListPage(contacts: contacts),
      ),
    );
  }

  Widget buildDialButton(String label) {
    return ElevatedButton(
      onPressed: () => addDigit(label),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.grey[200],
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Composer un numéro")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            number,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              crossAxisCount: 3,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#']
                    .map((e) => buildDialButton(e)),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.backspace, color: Colors.red),
                onPressed: deleteLast,
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: number.isEmpty ? null : callNumber,
                icon: const Icon(Icons.call),
                label: const Text("Appeler"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'contacts',
            onPressed: openContacts,
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.contacts),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'save',
            onPressed: () {
              saveContact(context, number); // Passe le numéro ici
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.save),
          ),
        ],
      ),
    );
  }
}

class ContactsListPage extends StatelessWidget {
  final List<Contact> contacts;

  const ContactsListPage({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            title: Text(contact.displayName),
            subtitle: Text(
              contact.phones.isNotEmpty ? contact.phones.first.number : 'Aucun numéro',
            ),
          );
        },
      ),
    );
  }
}
