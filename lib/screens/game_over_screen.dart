import 'package:flutter/material.dart';

/// Game Over ekranı - Oyun bittiğinde gösterilir
class GameOverScreen extends StatelessWidget {
  final int score;
  final int highScore;
  final VoidCallback onRestart;

  const GameOverScreen({
    super.key,
    required this.score,
    required this.highScore,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Mısır teması: Kumsal renk gradyanı (koyulaştırılmış)
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD4AF37), // Altın sarısı
              Color(0xFFC19A6B), // Koyu kum
              Color(0xFF8B7355), // Çok koyu kum
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game Over title
              const Text(
                '☠️ GAME OVER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B0000), // Dark red
                  shadows: [
                    Shadow(
                      offset: Offset(3, 3),
                      blurRadius: 5,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Score card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B4513).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4AF37),
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 5),
                      blurRadius: 15,
                      color: Colors.black38,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'YOUR SCORE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // High score
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Color(0xFFD4AF37),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Best: $highScore',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // TODO: Future ad integration
              // Example: _showRewardedAd() for rewarded ad
              // or _showInterstitialAd() for interstitial ad
              
              // Play again button
              ElevatedButton.icon(
                onPressed: () {
                  print('🔄 PLAY AGAIN pressed - restarting same difficulty level');
                  // Pop game over screen and go back to game
                  Navigator.pop(context);
                  // Call restart callback
                  onRestart();
                },
                icon: const Icon(Icons.refresh, size: 28),
                label: const Text(
                  'PLAY AGAIN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22), // Green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Main menu button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.home, size: 24),
                label: const Text(
                  'MAIN MENU',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B4513),
                  side: const BorderSide(
                    color: Color(0xFF8B4513),
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Motivational message
              Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _getMotivationalMessage(score),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns motivational message based on score
  String _getMotivationalMessage(int score) {
    if (score < 5) {
      return '🌟 Good start! You can do better!';
    } else if (score < 10) {
      return '🔥 Not bad! Keep going!';
    } else if (score < 20) {
      return '⭐ Great job! Don\'t give up!';
    } else if (score < 30) {
      return '🏆 Awesome! You\'re a true champion!';
    } else {
      return '👑 INCREDIBLE! You\'re the king of Egypt!';
    }
  }
}

