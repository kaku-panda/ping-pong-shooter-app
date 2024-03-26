import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yolov5_app/main.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:flutter_yolov5_app/data/model/classifier.dart';
import 'package:flutter_yolov5_app/utils/image_utils.dart';
import 'package:flutter_yolov5_app/data/entity/recognition.dart';

final recognitionsProvider = StateProvider<List<Recognition>>((ref) => []);

final mlCameraProvider = FutureProvider.autoDispose.family<MLCamera, Size>((ref, size) async {
  final cameras = await availableCameras();
  final cameraController = CameraController(
    cameras[0],
    ResolutionPreset.low,
    enableAudio: false,
  );
  await cameraController.initialize();
  final mlCamera = MLCamera(
    ref,
    cameraController,
    size,
  );
  return mlCamera;
});

class MLCamera {
  MLCamera(
    this._ref,
    this.cameraController,
    this.cameraViewSize,
  ) {
    Future(() async {
      classifier = Classifier(
        useGPU: _ref.read(settingProvider).useGPU,
        modelName: _ref.read(settingProvider).modelName,
      );
      await cameraController.startImageStream(onCameraAvailable);
    });
  }

  final Ref _ref;
  final CameraController cameraController;

  final Size cameraViewSize;

  late double ratio = Platform.isAndroid
      ? cameraViewSize.width / cameraController.value.previewSize!.height
      : cameraViewSize.width / cameraController.value.previewSize!.height;

  late Size actualPreviewSize = Size(
    cameraViewSize.width,
    cameraViewSize.width * ratio,
  );

  late Classifier classifier;

  bool isPredicting = false;

  Future<void> onCameraAvailable(CameraImage cameraImage) async {

    if(_ref.read(settingProvider).isStop){
      return;
    }

    if (classifier.interpreter == null) {
      return;
    }

    if (isPredicting) {
      return;
    }

    isPredicting = true;
    
    final startTime = DateTime.now();

    final isolateCamImgData = IsolateData(
      cameraImage: cameraImage,
      interpreterAddress: classifier.interpreter!.address,
    );
    _ref.read(recognitionsProvider.notifier).state = await compute(inference, isolateCamImgData);
    
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    _ref.read(settingProvider).predictionDurationMs = duration.inMilliseconds;

    isPredicting = false;
  }

  /// inference function
  static Future<List<Recognition>> inference(
      IsolateData isolateCamImgData
      ) async {
    
    late image_lib.Image image;

    if(isolateCamImgData.cameraImage.format.group == ImageFormatGroup.yuv420){
      image = ImageUtils.convertYUV420ToImage(
        isolateCamImgData.cameraImage,
      );
    }else if(isolateCamImgData.cameraImage.format.group == ImageFormatGroup.bgra8888){
      image = ImageUtils.convertBGRAToImage(
        isolateCamImgData.cameraImage,
      );
    }else{
      image = ImageUtils.convertBGRAToImage(
        isolateCamImgData.cameraImage,
      );
    }
    
    if (Platform.isAndroid) {
      image = image_lib.copyRotate(image, 90);
    }

    final classifier = Classifier(
      interpreter: Interpreter.fromAddress(
        isolateCamImgData.interpreterAddress,
      ),
    );

    return classifier.predict(image);
  }
}

class IsolateData {
  IsolateData({
    required this.cameraImage,
    required this.interpreterAddress,
  });
  final CameraImage cameraImage;
  final int interpreterAddress;
}
