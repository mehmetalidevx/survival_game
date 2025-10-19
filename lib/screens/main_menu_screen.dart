import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../game/egypt_survival_game.dart';
import '../services/audio_manager.dart';

/// Ana menü ekranı - Zorluk seçimi ve oyuna başlama
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  DifficultyLevel selectedDifficulty = DifficultyLevel.medium;
  final AudioManager _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    // Start background music with a delay to ensure audio system is ready
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        print('🎵 Attempting to start background music...');
        _audioManager.playBackgroundMusic().then((_) {
          print('✅ Background music started successfully');
        }).catchError((e) {
          print('⚠️ Background music failed: $e');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Mısır teması: Kumsal renk gradyanı
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8D5B7), // Açık kum rengi
              Color(0xFFD4AF37), // Altın sarısı
              Color(0xFFC19A6B), // Koyu kum
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game title
              const Text(
                '🏜️ EGYPT\nADVENTURE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513), // Dark brown
                  shadows: [
                    Shadow(
                      offset: Offset(3, 3),
                      blurRadius: 5,
                      color: Colors.black26,
                    ),
                  ],
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              // Decorative pyramid icon
              const Text(
                '🔺',
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 30),
              
              // Difficulty selection title
              const Text(
                'SELECT DIFFICULTY',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
              const SizedBox(height: 20),
              
              // Difficulty buttons
              _buildDifficultyButtons(),
              
              const SizedBox(height: 40),
              // Start game button
              ElevatedButton(
                onPressed: () async {
                  print('🎮 START GAME button pressed!');
                  
                  // Play menu click sound
                  _audioManager.playMenuClickSound();
                  
                  try {
                    // Ensure background music starts (especially important for web)
                    await _audioManager.playBackgroundMusic().catchError((e) {
                      print('Music start error (non-blocking): $e');
                    });
                    
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(difficulty: selectedDifficulty),
                        ),
                      );
                    }
                  } catch (e) {
                    print('❌ Error navigating to game: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513), // Dark brown
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  'START GAME',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37), // Gold
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Game instructions
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  '⚠️ Tap to jump!\n'
                  '🪨 Avoid the obstacles!\n'
                  '🏅 Survive!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Zorluk seviyesi butonları
  Widget _buildDifficultyButtons() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _buildDifficultyButton(DifficultyLevel.easy, '⭐ EASY', const Color(0xFF90EE90)),
        _buildDifficultyButton(DifficultyLevel.medium, '⭐⭐ MEDIUM', const Color(0xFFFFD700)),
        _buildDifficultyButton(DifficultyLevel.hard, '⭐⭐⭐ HARD', const Color(0xFFFF8C00)),
        _buildDifficultyButton(DifficultyLevel.veryHard, '⭐⭐⭐⭐ VERY HARD', const Color(0xFFFF4500)),
        _buildDifficultyButton(DifficultyLevel.extreme, '⭐⭐⭐⭐⭐ EXTREME', const Color(0xFF8B0000)),
      ],
    );
  }

  /// Tek bir zorluk seviyesi butonu
  Widget _buildDifficultyButton(DifficultyLevel level, String label, Color color) {
    final isSelected = selectedDifficulty == level;
    
    return ElevatedButton(
      onPressed: () {
        print('Difficulty button pressed: $level');
        
        // Play menu click sound
        _audioManager.playMenuClickSound();
        
        setState(() {
          selectedDifficulty = level;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : color.withOpacity(0.3),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
        elevation: isSelected ? 8 : 2,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

