import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playAudio(String url) async {
    try {
      await _player.setUrl(url);
      _player.play();
    } catch (e) {
      print('Erreur lecture audio: $e');
    }
  }

  void stopAudio() {
    _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
