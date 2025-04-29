import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final picker = ImagePicker();

  final String userPhone = "+224625617377"; 
  final String contactPhone = "+224622273577";

  Future<void> _sendMessage({String text = '', String? imageUrl, String? audioUrl}) async {
    final timestamp = FieldValue.serverTimestamp();

    await _firestore.collection('messages').add({
      'from': userPhone,
      'to': contactPhone,
      'texte': text,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
    });
    _controller.clear();
  }

  Future<void> _sendImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final ref = _storage.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(File(pickedFile.path));
      final url = await ref.getDownloadURL();
      _sendMessage(imageUrl: url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat International"),
        actions: [
          IconButton(
            icon: Icon(Icons.photo),
            onPressed: _sendImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['from'] == userPhone;
                    return MessageBubble(
                      text: data['texte'] ?? '',
                      isMe: isMe,
                      audioUrl: data['audioUrl'],
                      imageUrl: data['imageUrl'],
                      timestamp: (data['timestamp'] as Timestamp).toDate(),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Tapez un message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(text: _controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
