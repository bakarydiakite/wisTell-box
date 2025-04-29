import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String? audioUrl;
  final String? imageUrl;
  final DateTime timestamp;

  MessageBubble({
    required this.text,
    required this.isMe,
    this.audioUrl,
    this.imageUrl,
    required this.timestamp,
  });

  final AudioService _audioService = AudioService();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null) 
              Image.network(imageUrl!, width: 200),
            if (audioUrl != null) 
              IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {
                  _audioService.playAudio(audioUrl!);
                },
              ),
            if (text.isNotEmpty) 
              Text(text, style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text(
              '${timestamp.hour}:${timestamp.minute}',
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
