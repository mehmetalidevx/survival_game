import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/egypt_survival_game.dart';
import 'game_over_screen.dart';

/// Oyun ekranı - Flame oyun widget'ını içerir
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.difficulty = DifficultyLevel.medium});

  final DifficultyLevel difficulty;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late EgyptSurvivalGame game;

  @override
  void initState() {
    super.initState();
    game = EgyptSurvivalGame(difficulty: widget.difficulty);
    
    // Oyun bittiğinde game over ekranını göster
    game.onGameOver = () {
      _showGameOverScreen();
    };
  }

  void _showGameOverScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameOverScreen(
          score: game.score,
          highScore: game.highScore,
          onRestart: _restartGame,
        ),
      ),
    );
  }

  void _restartGame() {
    // Oyunu yeniden başlat - aynı zorluk seviyesinde
    print('🔄 Restarting game with difficulty: ${widget.difficulty}');
    setState(() {
      game = EgyptSurvivalGame(difficulty: widget.difficulty);
      game.onGameOver = () {
        _showGameOverScreen();
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Flame oyun widget'ı
          GameWidget(game: game),
          
          // Geri düğmesi - sol üst köşe (en üstte)
          Positioned(
            left: 10,
            top: 10,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF8B4513).withOpacity(0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFD4AF37),
                  size: 28,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

