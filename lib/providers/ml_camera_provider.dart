// MLCameraManager.dart
import 'package:flutter/widgets.dart';
import 'package:camera/camera.dart';
import 'package:flutter_yolov5_app/data/model/ml_camera.dart';

class MLCameraProvider extends ChangeNotifier {
  late CameraController _cameraController;
  late MLCamera _mlCamera;

  MLCameraProvider(Size size, bool useGPU, String modelName, bool isStop) {
    initializeCamera(size, useGPU, modelName, isStop);
  }

  Future<void> initializeCamera(Size size, bool useGPU, String modelName, bool isStop) async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController.initialize();

    _mlCamera = MLCamera(
      _cameraController,
      size,
      useGPU,
      modelName,
      isStop,
    );

    notifyListeners();
  }

  MLCamera get camera => _mlCamera;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}