import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart' show Colors;
import '../egypt_survival_game.dart';
import '../../services/audio_manager.dart';

/// Oyuncu komponenti - Altın böcek/Horus'un Gözü temalı top
/// Dokunmatik kontrol ile zıplar
class Player extends CircleComponent
    with HasGameRef<EgyptSurvivalGame>, CollisionCallbacks {
  Player({
    required Vector2 position,
    required double radius,
  }) : super(
          position: position,
          radius: radius,
          anchor: Anchor.center,
        );

  // Fizik değişkenleri
  double velocityY = 0; // Dikey hız
  final double gravity = 1200; // Yerçekimi (piksel/saniye²)
  final double jumpForce = -500; // Zıplama kuvveti
  final double maxFallSpeed = 800; // Maksimum düşüş hızı

  bool isAlive = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Çarpışma algılama ekle
    add(CircleHitbox(
      radius: radius,
      anchor: Anchor.center,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isAlive) return;

    // Yerçekimi uygula
    velocityY += gravity * dt;

    // Maksimum düşüş hızını sınırla
    if (velocityY > maxFallSpeed) {
      velocityY = maxFallSpeed;
    }

    // Pozisyonu güncelle
    position.y += velocityY * dt;

    // Ekran sınırları kontrolü
    final gameHeight = gameRef.size.y;
    
    // Yere çarpma kontrolü
    if (position.y + radius >= gameHeight) {
      position.y = gameHeight - radius;
      velocityY = 0;
    }

    // Tavana çarpma kontrolü
    if (position.y - radius <= 0) {
      position.y = radius;
      velocityY = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    // Altın böcek temalı top çiz - sadece ana top
    // Dış halka (altın rengi)
    final outerPaint = Paint()
      ..color = const Color(0xFFD4AF37) // Altın sarısı
      ..style = PaintingStyle.fill;

    // İç daire (koyu altın)
    final innerPaint = Paint()
      ..color = const Color(0xFFB8860B) // Koyu altın
      ..style = PaintingStyle.fill;

    // Göz detayı (Horus'un Gözü teması)
    final eyePaint = Paint()
      ..color = const Color(0xFF000080) // Koyu mavi
      ..style = PaintingStyle.fill;

    // Ana gölge efekti
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawCircle(Offset(2, 2), radius, shadowPaint);

    // Dış daire
    canvas.drawCircle(Offset.zero, radius, outerPaint);
    
    // İç daire
    canvas.drawCircle(Offset.zero, radius * 0.7, innerPaint);
    
    // Göz (Horus'un Gözü teması) - sadece koyu mavi göz, beyaz daire yok
    canvas.drawCircle(Offset(radius * 0.2, -radius * 0.2), radius * 0.15, eyePaint);

    super.render(canvas);
  }

  /// Zıplama fonksiyonu - ekrana dokunulduğunda çağrılır
  void jump() {
    if (!isAlive) return;
    velocityY = jumpForce;
    
    // Play jump sound
    AudioManager().playJumpSound();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    // Çarpışma kontrolü oyun sınıfında yapılacak
  }
}

