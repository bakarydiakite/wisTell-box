import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class ConnectionPhone extends StatefulWidget {
  const ConnectionPhone({super.key});

  @override
  State<ConnectionPhone> createState() => _ConnectionPhoneState();
}

class _ConnectionPhoneState extends State<ConnectionPhone> {
  String phoneNumber = '';
  bool codeSent = false;
  String verificationCode = '';
  final TextEditingController codeController = TextEditingController();

  final String baseUrl = 'http://192.168.34.227:8000/api/auth';

  Future<void> sendCode() async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Entrez un numéro valide")));
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/send-otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phoneNumber}),
    );

    if (response.statusCode == 200) {
      setState(() {
        codeSent = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('📩 Code envoyé')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : ${response.body}')));
    }
  }

  Future<void> verifyCode() async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phoneNumber,
        'code': codeController.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user', data['user']);
      await prefs.setString('phone', phoneNumber); // ✅ sauvegarde du numéro

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Code invalide')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion via Téléphone")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            IntlPhoneField(
              initialCountryCode: 'GN',
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                border: OutlineInputBorder(),
              ),
              onChanged: (phone) {
                phoneNumber = phone.completeNumber;
              },
            ),
            const SizedBox(height: 16),
            if (!codeSent)
              ElevatedButton(
                onPressed: sendCode,
                child: const Text("Envoyer le code"),
              ),
            if (codeSent) ...[
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Code OTP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: verifyCode,
                child: const Text("Valider le code"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
