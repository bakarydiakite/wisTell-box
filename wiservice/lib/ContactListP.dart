import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactListPage extends StatelessWidget {
  final List<Contact> contacts;
  const ContactListPage(this.contacts, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes contacts')),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          final phoneNumber = contact.phones.isNotEmpty
              ? contact.phones.first.number
              : '';

          return ListTile(
            title: Text(contact.displayName),
            subtitle: Text(phoneNumber),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (phoneNumber.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () => callNumber(phoneNumber),
                  ),
                if (phoneNumber.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.message, color: Colors.blue),
                    onPressed: () => sendSMS(phoneNumber),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> callNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Impossible d\'appeler $phoneNumber';
    }
  }

  Future<void> sendSMS(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Impossible d\'envoyer SMS à $phoneNumber';
    }
  }
}
