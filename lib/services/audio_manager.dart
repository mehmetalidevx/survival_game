import 'package:audioplayers/audioplayers.dart';

/// Oyun ses yöneticisi
/// Arka plan müziği, efekt sesleri ve ses seviyesi kontrolü
class AudioManager {
  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // Audio players - lazy initialization
  AudioPlayer? _backgroundMusic;
  AudioPlayer? _sfxPlayer;
  AudioPlayer? _menuSfxPlayer; // Separate player for menu sounds

  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  bool _isInitialized = false;

  /// Initialize audio manager
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _backgroundMusic = AudioPlayer();
      _sfxPlayer = AudioPlayer();
      _menuSfxPlayer = AudioPlayer(); // Separate player for menu sounds
      
      // Set audio mode
      await _backgroundMusic?.setReleaseMode(ReleaseMode.loop);
      await _sfxPlayer?.setReleaseMode(ReleaseMode.stop);
      await _menuSfxPlayer?.setReleaseMode(ReleaseMode.stop);
      
      // Try to set friendly audio contexts per player but NEVER fail init if not supported
      try {
        await _backgroundMusic?.setAudioContext(AudioContext(
          android: AudioContextAndroid(
            audioFocus: AndroidAudioFocus.gain,
            usageType: AndroidUsageType.media,
            contentType: AndroidContentType.music,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
        ));
      } catch (e) {
        print('AudioContext set failed for background music (ignored): $e');
      }
      try {
        await _sfxPlayer?.setAudioContext(AudioContext(
          android: AudioContextAndroid(
            audioFocus: AndroidAudioFocus.none,
            usageType: AndroidUsageType.assistanceSonification,
            contentType: AndroidContentType.sonification,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
        ));
      } catch (e) {
        print('AudioContext set failed for sfx (ignored): $e');
      }
      try {
        await _menuSfxPlayer?.setAudioContext(AudioContext(
          android: AudioContextAndroid(
            audioFocus: AndroidAudioFocus.none,
            usageType: AndroidUsageType.assistanceSonification,
            contentType: AndroidContentType.sonification,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
        ));
      } catch (e) {
        print('AudioContext set failed for menu sfx (ignored): $e');
      }

      _isInitialized = true;
      print('AudioManager initialized successfully');
    } catch (e) {
      print('Error initializing AudioManager: $e');
      // Do not disable audio entirely; allow best-effort playback
      _isInitialized = true;
    }
  }

  /// Play background music
  Future<void> playBackgroundMusic() async {
    print('🎵 playBackgroundMusic called');
    print('   - Music enabled: $_isMusicEnabled');
    print('   - Initialized: $_isInitialized');
    print('   - Player exists: ${_backgroundMusic != null}');
    
    if (!_isMusicEnabled || !_isInitialized || _backgroundMusic == null) {
      print('⚠️ Background music cannot play - conditions not met');
      return;
    }
    
    try {
      print('🎵 Ensuring background music is playing: assets/sounds/background_music.mp3');
      await _backgroundMusic?.play(AssetSource('sounds/background_music.mp3'));
      await _backgroundMusic?.setVolume(0.3); // 30% volume for background
      print('✅ Background music playing at 30% volume');
    } catch (e) {
      print('❌ Error playing background music: $e');
      // Silently fail if audio file not found
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    if (_backgroundMusic == null) return;
    try {
      await _backgroundMusic?.stop();
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

  /// Pause background music
  Future<void> pauseBackgroundMusic() async {
    if (_backgroundMusic == null) return;
    try {
      await _backgroundMusic?.pause();
    } catch (e) {
      print('Error pausing background music: $e');
    }
  }

  /// Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled || _backgroundMusic == null) return;
    try {
      await _backgroundMusic?.resume();
    } catch (e) {
      print('Error resuming background music: $e');
    }
  }

  /// Play jump sound
  Future<void> playJumpSound() async {
    if (!_isSfxEnabled || !_isInitialized || _sfxPlayer == null) return;
    
    try {
      await _sfxPlayer?.stop();
      await _sfxPlayer?.play(AssetSource('sounds/jump.mp3'));
      await _sfxPlayer?.setVolume(0.5); // 50% volume for SFX
    } catch (e) {
      print('Error playing jump sound: $e');
      // Silently fail if audio file not found
    }
  }

  /// Play game over sound
  Future<void> playGameOverSound() async {
    if (!_isSfxEnabled || !_isInitialized || _sfxPlayer == null) return;
    
    try {
      await _sfxPlayer?.stop();
      await _sfxPlayer?.play(AssetSource('sounds/game_over.mp3'));
      await _sfxPlayer?.setVolume(0.6); // 60% volume for game over
    } catch (e) {
      print('Error playing game over sound: $e');
      // Silently fail if audio file not found
    }
  }

  /// Play menu selection/button click sound (uses separate player to not interrupt music)
  Future<void> playMenuClickSound() async {
    if (!_isSfxEnabled || !_isInitialized || _menuSfxPlayer == null) return;
    
    try {
      await _menuSfxPlayer?.stop();
      await _menuSfxPlayer?.play(AssetSource('sounds/menu-selection-102220.mp3'));
      await _menuSfxPlayer?.setVolume(0.4); // 40% volume for menu clicks
      print('🔊 Menu click sound played');
    } catch (e) {
      print('Error playing menu click sound: $e');
      // Silently fail if audio file not found
    }
  }

  /// Toggle music on/off
  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;
    if (!_isMusicEnabled) {
      stopBackgroundMusic();
    } else {
      playBackgroundMusic();
    }
  }

  /// Toggle sound effects on/off
  void toggleSfx() {
    _isSfxEnabled = !_isSfxEnabled;
  }

  /// Dispose audio players
  Future<void> dispose() async {
    try {
      await _backgroundMusic?.dispose();
      await _sfxPlayer?.dispose();
      await _menuSfxPlayer?.dispose();
    } catch (e) {
      print('Error disposing audio players: $e');
    }
  }

  // Getters
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
}

