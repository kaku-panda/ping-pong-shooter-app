import 'package:camera/camera.dart';
import 'package:image/image.dart' as image_lib;

class ImageUtils {
  static image_lib.Image convertYUV420ToImage(CameraImage cameraImage) {
    
    final width = cameraImage.width;
    final height = cameraImage.height;

    final uvRowStride = cameraImage.planes[0].bytesPerRow;
    final uvPixelStride = cameraImage.planes[0].bytesPerPixel;

    final image = image_lib.Image(width, height);

    for (var w = 0; w < width; w++) {
      for (var h = 0; h < height; h++) {
        final uvIndex =
            uvPixelStride! * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final index = h * width + w;

        final y = cameraImage.planes[0].bytes[index];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        image.data[index] = ImageUtils.yuv2rgb(y, u, v);
      }
    }
    return image;
  }

  static int yuv2rgb(int y, int u, int v) {
    // Convert yuv pixel to rgb
    var r = (y + v * 1436 / 1024 - 179).round();
    var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    var b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255).toInt();
    g = g.clamp(0, 255).toInt();
    b = b.clamp(0, 255).toInt();

    return 0xff000000 |
    ((b << 16) & 0xff0000) |
    ((g << 8) & 0xff00) |
    (r & 0xff);
  }

  static image_lib.Image convertBGRAToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final image = image_lib.Image(width, height);

    // BGRA形式のカメライメージから各ピクセルの色を取得してImageオブジェクトにセット
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // BGRAフォーマットなので、1ピクセルあたり4バイト
        final pixelOffset = (y * width + x) * 4;
        final blue = cameraImage.planes[0].bytes[pixelOffset];
        final green = cameraImage.planes[0].bytes[pixelOffset + 1];
        final red = cameraImage.planes[0].bytes[pixelOffset + 2];
        final alpha = cameraImage.planes[0].bytes[pixelOffset + 3];
        // image ライブラリの setImage でピクセルの色を設定
        image.setPixelRgba(x, y, red, green, blue, alpha);
      }
    }

    return image;
  }
}
