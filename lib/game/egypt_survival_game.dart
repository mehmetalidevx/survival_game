import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show TextStyle, TextSpan, TextPainter, TextDirection, FontWeight;
import 'components/player.dart';
import 'components/spike.dart';
import '../services/audio_manager.dart';

/// Zorluk seviyeleri
enum DifficultyLevel {
  easy,
  medium,
  hard,
  veryHard,
  extreme,
}

/// Ana oyun sınıfı - Mısır temalı hayatta kalma oyunu
/// 60 FPS hedef ile çalışır
class EgyptSurvivalGame extends FlameGame
    with TapDetector, HasCollisionDetection {
  EgyptSurvivalGame({this.difficulty = DifficultyLevel.medium}) {
    _setupDifficulty();
  }

  final DifficultyLevel difficulty;

  late Player player;
  int score = 0;
  int highScore = 0;
  bool isGameOver = false;
  
  // Statik high score - uygulama açıkken kalıcı (her zorluk için ayrı)
  static final Map<DifficultyLevel, int> _sessionHighScores = {
    DifficultyLevel.easy: 0,
    DifficultyLevel.medium: 0,
    DifficultyLevel.hard: 0,
    DifficultyLevel.veryHard: 0,
    DifficultyLevel.extreme: 0,
  };
  
  // Spike spawn ayarları (zorluk seviyesine göre değişir)
  double spawnTimer = 0;
  late double spawnInterval;
  late double minSpawnInterval;
  late double spawnIntervalDecrease;
  
  // Oyun zorluk ayarları
  double currentDifficulty = 1.0;
  late double difficultyIncreaseRate;
  late double baseSpeed;

  // Skor artırma zamanlayıcısı
  double scoreTimer = 0;
  final double scoreInterval = 1.0; // Her saniye 1 puan

  // Callback fonksiyonu - oyun bittiğinde çağrılır
  Function? onGameOver;

  /// Zorluk seviyesine göre oyun ayarlarını yapılandır
  void _setupDifficulty() {
    switch (difficulty) {
      case DifficultyLevel.easy:
        spawnInterval = 2.0;
        minSpawnInterval = 1.2;
        spawnIntervalDecrease = 0.02;
        difficultyIncreaseRate = 0.08;
        baseSpeed = 180;
        break;
      case DifficultyLevel.medium:
        spawnInterval = 1.5;
        minSpawnInterval = 0.8;
        spawnIntervalDecrease = 0.04;
        difficultyIncreaseRate = 0.15;
        baseSpeed = 220;
        break;
      case DifficultyLevel.hard:
        spawnInterval = 1.2;
        minSpawnInterval = 0.6;
        spawnIntervalDecrease = 0.05;
        difficultyIncreaseRate = 0.22;
        baseSpeed = 270;
        break;
      case DifficultyLevel.veryHard:
        spawnInterval = 1.0;
        minSpawnInterval = 0.45;
        spawnIntervalDecrease = 0.06;
        difficultyIncreaseRate = 0.3;
        baseSpeed = 320;
        break;
      case DifficultyLevel.extreme:
        spawnInterval = 0.8;
        minSpawnInterval = 0.3;
        spawnIntervalDecrease = 0.08;
        difficultyIncreaseRate = 0.4;
        baseSpeed = 380;
        break;
    }
  }

  @override
  Color backgroundColor() => const Color(0xFFE8D5B7); // Kum rengi arka plan

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // FPS ayarı - varsayılan 60 FPS
    // Flame otomatik olarak 60 FPS'de çalışır

    // En yüksek skoru yükle (zorluk seviyesine özel)
    highScore = _sessionHighScores[difficulty] ?? 0;

    // Oyuncu oluştur
    player = Player(
      position: Vector2(size.x * 0.3, size.y * 0.5),
      radius: 25,
    );
    await add(player);

    // Arka plan komponenti ekle
    await add(BackgroundComponent());

    // İlk spike'ları oluştur
    _spawnInitialSpikes();
  }

  /// En yüksek skoru kaydet (oturum boyunca, zorluk seviyesine özel)
  void _saveHighScore() {
    if (score > highScore) {
      highScore = score;
      _sessionHighScores[difficulty] = highScore;
    }
    
    // TODO: Kalıcı kayıt için SharedPreferences kullanılabilir
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setInt('highScore_${difficulty.name}', highScore);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver) return;

    // Skor zamanlayıcı - sürekli artan skor
    scoreTimer += dt;
    if (scoreTimer >= scoreInterval) {
      score++;
      scoreTimer = 0;
    }

    // Spike spawn zamanlayıcı
    spawnTimer += dt;
    if (spawnTimer >= spawnInterval) {
      _spawnSpike();
      spawnTimer = 0;
      
      // Zorluk artışı - spawn aralığını azalt
      if (spawnInterval > minSpawnInterval) {
        spawnInterval -= spawnIntervalDecrease;
      }
    }

    // Zorluk seviyesi güncelle
    currentDifficulty = 1.0 + (score * difficultyIncreaseRate / 10);

    // Çarpışma kontrolü
    _checkCollisions();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isGameOver) return;

    // Score display (top left)
    const scoreStyle = TextStyle(
      color: Color(0xFF8B4513),
      fontSize: 28,
      fontWeight: FontWeight.bold,
    );
    
    final scoreSpan = TextSpan(text: 'Score: $score', style: scoreStyle);
    final scorePainter = TextPainter(
      text: scoreSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    
    scorePainter.paint(canvas, const Offset(20, 50));

    // High score display (top right)
    const highScoreStyle = TextStyle(
      color: Color(0xFFD4AF37), // Gold color
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
    
    final highScoreSpan = TextSpan(text: 'Best: $highScore', style: highScoreStyle);
    final highScorePainter = TextPainter(
      text: highScoreSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    
    // Top right corner
    final highScoreX = size.x - highScorePainter.width - 20;
    highScorePainter.paint(canvas, Offset(highScoreX, 50));

    // TODO: Gelecekte API entegrasyonu için reklam banner'ı buraya eklenebilir
    // API çağrısı: _showBannerAd() gibi bir fonksiyon ile
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    if (!isGameOver) {
      player.jump();
    }
  }

  /// İlk spike'ları oluştur
  void _spawnInitialSpikes() {
    final random = Random();
    for (int i = 0; i < 3; i++) {
      final spike = Spike(
        position: Vector2(
          size.x + (i * 300.0),
          _getRandomSpikeY(random),
        ),
        width: 40,
        height: 60,
      );
      add(spike);
    }
  }

  /// Yeni spike oluştur (sağdan sola hareket)
  void _spawnSpike() {
    final random = Random();
    
    final spike = Spike(
      position: Vector2(size.x + 50, _getRandomSpikeY(random)),
      width: 40,
      height: 60,
    );
    
    // Zorluk seviyesine göre hızı artır - base speed + difficulty multiplier
    spike.moveSpeed = baseSpeed + (currentDifficulty * 50);
    
    add(spike);
  }

  /// Rastgele spike Y pozisyonu (yerden, tavandan veya ortadan)
  double _getRandomSpikeY(Random random) {
    // Rastgele pozisyon seç
    final choice = random.nextInt(5);
    
    switch (choice) {
      case 0:
        // Yerden çıkan spike (altta)
        return size.y;
      case 1:
        // Tavandan sarkan spike (üstte)
        return 0;
      case 2:
        // Ortada - üst kısım
        return size.y * 0.3;
      case 3:
        // Ortada - orta kısım
        return size.y * 0.5;
      case 4:
        // Ortada - alt kısım
        return size.y * 0.7;
      default:
        return size.y;
    }
  }

  /// Çarpışma kontrolü
  void _checkCollisions() {
    for (final component in children) {
      if (component is Spike) {
        // Player ile spike çarpışması kontrolü
        final dx = player.position.x - component.position.x;
        final dy = player.position.y - component.position.y;
        final distance = sqrt(dx * dx + dy * dy);
        
        // Basit çarpışma algılama - mesafe kontrolü
        if (distance < player.radius + 25) {
          _gameOver();
          return;
        }
      }
    }
  }

  /// Oyun bitti
  void _gameOver() {
    if (isGameOver) return;
    
    isGameOver = true;
    player.isAlive = false;
    
    // En yüksek skoru kaydet
    _saveHighScore();
    
    // Play game over sound
    AudioManager().playGameOverSound();
    
    // Callback çağır
    if (onGameOver != null) {
      onGameOver!();
    }
    
    // TODO: Gelecekte API entegrasyonu
    // - Skor kaydetme: _saveScoreToAPI(score)
    // - Reklam gösterme: _showInterstitialAd()
    // - Liderlik tablosu güncelleme: _updateLeaderboard(score)
  }

  /// Oyunu yeniden başlat
  void restart() {
    isGameOver = false;
    score = 0;
    spawnTimer = 0;
    scoreTimer = 0;
    spawnInterval = 1.5;
    currentDifficulty = 1.0;

    // Tüm spike'ları temizle
    final spikesToRemove = children.whereType<Spike>().toList();
    for (final spike in spikesToRemove) {
      spike.removeFromParent();
    }

    // Oyuncuyu sıfırla
    player.position = Vector2(size.x * 0.3, size.y * 0.5);
    player.velocityY = 0;
    player.isAlive = true;

    // İlk spike'ları yeniden oluştur
    _spawnInitialSpikes();
  }
}

/// Arka plan komponenti - Mısır temalı dinamik arka plan
/// Yan kaydırma efekti için hareket eden desenler
class BackgroundComponent extends Component {
  double scrollOffset = 0;
  final double scrollSpeed = 30; // Yavaş yan kaydırma
  double waveOffset = 0;

  @override
  void update(double dt) {
    super.update(dt);
    
    final game = parent as EgyptSurvivalGame;
    if (!game.isGameOver) {
      scrollOffset += scrollSpeed * dt;
      waveOffset += dt * 2; // Dalga animasyonu
      
      // Sonsuz döngü için offset'i sıfırla
      if (scrollOffset > 200) {
        scrollOffset = 0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final gameSize = (parent as EgyptSurvivalGame).size;
    
    // Arka plan deseni - hiyeroglif tarzı desenler
    _drawBackgroundPattern(canvas, gameSize);
    
    // Hareket eden kum tepeleri (parallax efekti)
    _drawSandDunes(canvas, gameSize);
  }

  void _drawBackgroundPattern(Canvas canvas, Vector2 size) {
    final patternPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Hiyeroglif tarzı desenler
    for (int i = 0; i < 5; i++) {
      final x = (i * size.x / 4 - scrollOffset * 0.5) % size.x;
      final y = size.y * 0.2 + (i % 2) * size.y * 0.3;
      
      // Ankh sembolü benzeri
      canvas.drawCircle(Offset(x, y), 15, patternPaint);
      canvas.drawLine(
        Offset(x, y + 15),
        Offset(x, y + 45),
        patternPaint,
      );
      canvas.drawLine(
        Offset(x - 15, y + 25),
        Offset(x + 15, y + 25),
        patternPaint,
      );
    }
  }

  void _drawSandDunes(Canvas canvas, Vector2 size) {
    final dunePaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Arka plandaki kum tepeleri
    for (int i = 0; i < 4; i++) {
      final x = (i * size.x / 3 - scrollOffset) % (size.x + 200) - 100;
      
      final path = Path()
        ..moveTo(x - 100, size.y)
        ..quadraticBezierTo(
          x, size.y * 0.8 + sin(waveOffset + i) * 10,
          x + 100, size.y,
        )
        ..lineTo(x - 100, size.y)
        ..close();

      canvas.drawPath(path, dunePaint);
    }

    // Alt taraftaki kum tepeleri
    for (int i = 0; i < 4; i++) {
      final x = (i * size.x / 3 - scrollOffset * 1.5) % (size.x + 200) - 100;
      
      final path = Path()
        ..moveTo(x - 80, size.y)
        ..quadraticBezierTo(
          x, size.y * 0.9 + sin(waveOffset * 1.5 + i) * 8,
          x + 80, size.y,
        )
        ..lineTo(x - 80, size.y)
        ..close();

      final frontDunePaint = Paint()
        ..color = const Color(0xFFD4AF37).withOpacity(0.25)
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, frontDunePaint);
    }
  }
}

