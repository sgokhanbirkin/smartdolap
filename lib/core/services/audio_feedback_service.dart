import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:smartdolap/core/utils/logger.dart';

/// Service for providing audio feedback to user actions
/// Uses both system sounds and custom audio files for better UX
class AudioFeedbackService {
  AudioFeedbackService._();

  static final AudioPlayer _player = AudioPlayer();
  static bool _isInitialized = false;

  /// Initialize the audio player
  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(1.0);
      _isInitialized = true;
      Logger.info('[AudioFeedback] Initialized');
    } on Object catch (e) {
      Logger.error('[AudioFeedback] Failed to initialize', e);
    }
  }

  /// Play a "dit" sound for successful scan detection
  /// This is the instant feedback when barcode is detected
  static Future<void> playDitSound() async {
    try {
      await initialize();

      // Try to play custom dit sound if available
      try {
        await _player.play(AssetSource('sounds/dit.mp3'));
        Logger.info('[AudioFeedback] Played dit sound (custom)');
      } catch (_) {
        // Fallback to system click if custom sound not available
        await SystemSound.play(SystemSoundType.click);
        Logger.info('[AudioFeedback] Played dit sound (system fallback)');
      }
    } on Object catch (e) {
      Logger.error('[AudioFeedback] Failed to play dit sound', e);
    }
  }

  /// Play a beep sound for successful scan (legacy method)
  static Future<void> playSuccessBeep() async {
    await playDitSound();
  }

  /// Play a double beep for error/not found
  static Future<void> playErrorBeep() async {
    try {
      await initialize();

      // Play two quick system clicks for error
      await SystemSound.play(SystemSoundType.click);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await SystemSound.play(SystemSoundType.click);
      Logger.info('[AudioFeedback] Played error beep');
    } on Object catch (e) {
      Logger.error('[AudioFeedback] Failed to play error beep', e);
    }
  }

  /// Play alert sound for warnings
  static Future<void> playAlert() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
      Logger.info('[AudioFeedback] Played alert sound');
    } on Object catch (e) {
      Logger.error('[AudioFeedback] Failed to play alert', e);
    }
  }

  /// Dispose the audio player
  static Future<void> dispose() async {
    try {
      await _player.dispose();
      _isInitialized = false;
      Logger.info('[AudioFeedback] Disposed');
    } on Object catch (e) {
      Logger.error('[AudioFeedback] Failed to dispose', e);
    }
  }
}
