import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:plane_dash/data/consts/design.dart';
import 'package:plane_dash/presentation/view_models/game_view_model.dart'; // для Star, Obstacle

class GamePainter extends CustomPainter {
  final double planeX;
  final ui.Image? planeImage;
  final List<Star> stars;
  final List<Obstacle> obstacles;
  final Size screenSize;

  const GamePainter({
    required this.planeX,
    required this.planeImage,
    required this.stars,
    required this.obstacles,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawClouds(canvas);
    _drawStars(canvas);
    _drawObstacles(canvas);
    _drawPlane(canvas);
  }

  void _drawClouds(Canvas canvas) {
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final offset = (DateTime.now().millisecondsSinceEpoch / 50 % 800).toDouble();
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(50 + i * 80, (offset + i * 100) % 800, 80, 30),
          const Radius.circular(20),
        ),
        cloudPaint,
      );
    }
  }

  void _drawStars(Canvas canvas) {
    final starPaint = Paint()..color = AppColors.starYellow;
    for (var star in stars) {
      canvas.drawCircle(Offset(star.x, star.y), 15, starPaint);
      // Блик
      canvas.drawCircle(
        Offset(star.x - 3, star.y - 3),
        5,
        Paint()..color = Colors.white.withOpacity(0.7),
      );
    }
  }

  void _drawObstacles(Canvas canvas) {
    final obstaclePaint = Paint()..color = AppColors.obstacleDark;
    for (var obs in obstacles) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(obs.x, obs.y, obs.width, obs.height),
          const Radius.circular(8),
        ),
        obstaclePaint,
      );
      // Тень
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(obs.x + 2, obs.y + 2, obs.width, obs.height),
          const Radius.circular(8),
        ),
        Paint()..color = Colors.black.withOpacity(0.2),
      );
    }
  }

  void _drawPlane(Canvas canvas) {
    const planeY = 600.0; // фиксированная высота самолёта

    if (planeImage != null) {
      // Рисуем загруженное изображение
      canvas.drawImage(
        planeImage!,
        Offset(planeX - planeImage!.width / 2, planeY - planeImage!.height / 2),
        Paint(),
      );
    } else {
      _drawFallbackPlane(canvas, planeX, planeY);
    }
  }

  void _drawFallbackPlane(Canvas canvas, double x, double y) {
    final planePaint = Paint()
      ..color = AppColors.accentRed
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 25, y - 20, 50, 40),
        const Radius.circular(12),
      ),
      planePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(x - 35, y - 5, 70, 10),
      Paint()..color = AppColors.accentRed.withOpacity(0.8),
    );

    canvas.drawPath(
      Path()
        ..moveTo(x - 15, y - 20)
        ..lineTo(x - 25, y - 40)
        ..lineTo(x - 5, y - 30)
        ..close(),
      Paint()..color = AppColors.accentRed,
    );

    canvas.drawCircle(
      Offset(x + 10, y - 15),
      8,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(x + 12, y - 17),
      4,
      Paint()..color = Colors.blue,
    );
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    return oldDelegate.planeX != planeX ||
        oldDelegate.planeImage != planeImage ||
        oldDelegate.stars != stars ||
        oldDelegate.obstacles != obstacles;
  }
}