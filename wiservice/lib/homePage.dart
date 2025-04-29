import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RebtelHomePage extends StatefulWidget {
  const RebtelHomePage({super.key});

  @override
  State<RebtelHomePage> createState() => _RebtelHomePageState();
}

class _RebtelHomePageState extends State<RebtelHomePage> {
  String? userPhone;
  Future<String>? _soldeFuture;
  final String baseUrl = 'http://192.168.34.227:8000/api/auth';

  @override
  void initState() {
    super.initState();
    loadPhone();
  }

  Future<void> loadPhone() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phone');
    setState(() {
      userPhone = phone;
      _soldeFuture = fetchSolde();
    });
  }

  Future<String> fetchSolde() async {
    final response = await http.get(Uri.parse('$baseUrl/solde/?phone=$userPhone'));
    print("💬 STATUS: ${response.statusCode}");
    print("💬 BODY: ${response.body}");
     if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print("💬 MONTANT = ${data['montant']}");
    return '${data['montant']} GNF';
  } else {
    return 'Solde indisponible';
  }
}

  Future<List<dynamic>> fetchHistorique() async {
    final response = await http.get(Uri.parse('$baseUrl/appels/historique/?phone=$userPhone'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  void showRechargeDialog() async {
    final TextEditingController amountController = TextEditingController();
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phone') ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recharger le solde'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Montant (GNF)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final montant = amountController.text;
              if (montant.isNotEmpty && phone.isNotEmpty) {
                final response = await http.post(
                  Uri.parse('$baseUrl/solde/recharger/'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'phone': phone, 'montant': montant}),
                );

                Navigator.pop(context);

                if (response.statusCode == 200) {
                  setState(() {
                    _soldeFuture = fetchSolde(); // ⬅️ Recharge la valeur après paiement
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Solde rechargé')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur : ${response.body}')),
                  );
                }
              }
            },
            child: const Text('Recharger'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userPhone == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("WisTel",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: FutureBuilder<String>(
                future: _soldeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Solde...");
                  } else {
                    return Text(
                      "Solde: ${snapshot.data ?? "0 GNF"}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
            onPressed: showRechargeDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Rechercher un contact ou numéro",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Historique des appels",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchHistorique(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final appels = snapshot.data ?? [];

                if (appels.isEmpty) {
                  return const Center(child: Text("Aucun appel trouvé."));
                }

                return ListView.builder(
                  itemCount: appels.length,
                  itemBuilder: (context, index) {
                    final appel = appels[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.phone, color: Colors.white),
                      ),
                      title: Text(appel['numero']),
                      subtitle: Text(appel['date_appel']),
                      trailing: Icon(
                        appel['type_appel'] == 'OUT' ? Icons.call_made : Icons.call_received,
                        color: appel['type_appel'] == 'OUT' ? Colors.green : Colors.red,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/dialer'),
        backgroundColor: Colors.green,
        child: const Icon(Icons.dialpad),
      ),
    );
  }
}
