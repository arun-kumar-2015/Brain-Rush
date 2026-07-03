import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSuccess() async {
    // await _player.play(AssetSource('sounds/success.mp3'));
  }

  Future<void> playError() async {
    // await _player.play(AssetSource('sounds/error.mp3'));
  }

  Future<void> playClick() async {
    // await _player.play(AssetSource('sounds/click.mp3'));
  }

  void dispose() {
    _player.dispose();
  }
}
