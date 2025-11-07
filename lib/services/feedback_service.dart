import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class FeedbackService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  /// Reproduce vibración de error
  static Future<void> vibrateError() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        // Patrón de vibración: vibrar-pausa-vibrar (efecto de error)
        await Vibration.vibrate(pattern: [0, 200, 100, 200]);
      }
    } catch (e) {
      debugPrint('Error al vibrar: $e');
    }
  }

  /// Reproduce vibración de éxito
  static Future<void> vibrateSuccess() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        // Vibración simple de éxito
        await Vibration.vibrate(duration: 100);
      }
    } catch (e) {
      debugPrint('Error al vibrar: $e');
    }
  }

  /// Reproduce sonido de error
  static Future<void> playErrorSound() async {
    try {
      // Genera un sonido de error usando frecuencia baja
      await _audioPlayer.play(AssetSource('sounds/error.mp3'), volume: 0.5);
    } catch (e) {
      debugPrint('Error al reproducir sonido: $e');
    }
  }

  /// Reproduce sonido de éxito
  static Future<void> playSuccessSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/success.mp3'), volume: 0.5);
    } catch (e) {
      debugPrint('Error al reproducir sonido: $e');
    }
  }

  /// Feedback completo de error (vibración + sonido)
  static Future<void> errorFeedback() async {
    await Future.wait([vibrateError(), playErrorSound()]);
  }

  /// Feedback completo de éxito (vibración + sonido)
  static Future<void> successFeedback() async {
    await Future.wait([vibrateSuccess(), playSuccessSound()]);
  }

  /// Limpia recursos
  static void dispose() {
    _audioPlayer.dispose();
  }
}
