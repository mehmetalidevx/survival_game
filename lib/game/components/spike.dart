import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../egypt_survival_game.dart';

/// Diken komponenti - Mısır dikilitaşı/mızrak temalı engel
/// Sağdan sola doğru hareket eder (yan kaydırma oyunu)
class Spike extends PositionComponent
    with HasGameRef<EgyptSurvivalGame>, CollisionCallbacks {
  Spike({
    required Vector2 position,
    required this.width,
    required this.height,
  }) : super(
          position: position,
          size: Vector2(width, height),
          anchor: Anchor.center,
        );

  final double width;
  final double height;
  double moveSpeed = 200; // Hareket hızı (piksel/saniye)
  bool isFromBottom = true; // Yerden mi tavandan mı?

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Pozisyondan spike tipini belirle
    final gameHeight = gameRef.size.y;
    
    // Alt %30'da ise yerden, üst %30'da ise tavandan, ortada ise yana bakan
    if (position.y > gameHeight * 0.7) {
      isFromBottom = true; // Yerden
    } else if (position.y < gameHeight * 0.3) {
      isFromBottom = false; // Tavandan
    } else {
      isFromBottom = true; // Ortadakiler için varsayılan
    }

    // Dikilitaş şekli oluştur (üçgen)
    List<Vector2> vertices;
    if (position.y > gameHeight * 0.7) {
      // Yerden çıkan spike (yukarı bakan)
      vertices = [
        Vector2(0, -height / 2), // Tepe nokta
        Vector2(-width / 2, height / 2), // Sol alt
        Vector2(width / 2, height / 2), // Sağ alt
      ];
    } else if (position.y < gameHeight * 0.3) {
      // Tavandan sarkan spike (aşağı bakan)
      vertices = [
        Vector2(0, height / 2), // Tepe nokta (aşağı)
        Vector2(-width / 2, -height / 2), // Sol üst
        Vector2(width / 2, -height / 2), // Sağ üst
      ];
    } else {
      // Ortadaki spike'lar - sola bakan (yatay)
      vertices = [
        Vector2(-height / 2, 0), // Tepe nokta (sola)
        Vector2(width / 2, -width / 2), // Sağ üst
        Vector2(width / 2, width / 2), // Sağ alt
      ];
    }

    // Polygon şeklini ayarla
    _renderShape = Path()
      ..moveTo(vertices[0].x, vertices[0].y)
      ..lineTo(vertices[1].x, vertices[1].y)
      ..lineTo(vertices[2].x, vertices[2].y)
      ..close();

    // Çarpışma kutusu ekle
    add(PolygonHitbox(vertices));
  }

  Path? _renderShape;

  @override
  void update(double dt) {
    super.update(dt);

    // Sola doğru hareket et (yan kaydırma)
    position.x -= moveSpeed * dt;

    // Ekrandan çıktıysa kaldır
    if (position.x < -width) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_renderShape == null) return;

    // Dikilitaş desen çiz (Mısır temalı)
    final basePaint = Paint()
      ..color = const Color(0xFF8B7355) // Taş rengi
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF654321) // Koyu kahverengi
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final hieroglyphPaint = Paint()
      ..color = const Color(0xFFD4AF37) // Altın sarısı hiyeroglif
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Ana gövde
    canvas.drawPath(_renderShape!, basePaint);
    canvas.drawPath(_renderShape!, strokePaint);

    // Basit hiyeroglif desenleri
    if (isFromBottom) {
      canvas.drawLine(
        Offset(-width * 0.2, 0),
        Offset(width * 0.2, 0),
        hieroglyphPaint,
      );
      canvas.drawLine(
        Offset(-width * 0.15, height * 0.15),
        Offset(width * 0.15, height * 0.15),
        hieroglyphPaint,
      );
    } else {
      canvas.drawLine(
        Offset(-width * 0.2, 0),
        Offset(width * 0.2, 0),
        hieroglyphPaint,
      );
      canvas.drawLine(
        Offset(-width * 0.15, -height * 0.15),
        Offset(width * 0.15, -height * 0.15),
        hieroglyphPaint,
      );
    }

    super.render(canvas);
  }

  /// Hızı artır (zorluk arttıkça)
  void increaseSpeed(double amount) {
    moveSpeed += amount;
  }
}

