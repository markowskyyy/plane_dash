import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class ImageLoader {

  static Future<ui.Image?> loadAssetImage(String assetPath) async {
    print('🟢 Загружаю изображение: $assetPath');
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      print('❌ Ошибка загрузки изображения $assetPath: $e');
      return null;
    }
  }
}