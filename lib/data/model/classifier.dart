import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'package:flutter_yolov5_app/utils/logger.dart';
import 'package:flutter_yolov5_app/data/entity/recognition.dart';

class Classifier {
  Classifier({
    Interpreter? interpreter,
    bool? useGPU,
    String? modelName,
  }) {
    loadModel(interpreter, useGPU ?? false);
  }
  late Interpreter? _interpreter;
  Interpreter? get interpreter => _interpreter;

  ImageProcessor? imageProcessor;
  late int inputSize;
  late List<List<int>> outputShapes;
  late List<TfLiteType> _outputTypes;

  static const int clsNum = 80;
  static const double objConfTh = 0.60;
  static const double clsConfTh = 0.60;

  /// load interpreter
  Future<void> loadModel(Interpreter? interpreter, [bool useGPU = false, String modelName = 'coco128_float32.tflite']) async {
    try {
      var options = InterpreterOptions();

      if(interpreter == null){
        if(useGPU){
          final gpuDelegate = GpuDelegate(
            options: GpuDelegateOptions(
              allowPrecisionLoss: true,
              waitType: TFLGpuDelegateWaitType.active,
            ),
          );
          options.addDelegate(gpuDelegate);
        }else{
          options.threads = 4;
        }
      }
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            'ssd_mobilenet.tflite',
            // modelName,
            options: options,
          );
      inputSize = _interpreter!.getInputTensor(0).shape[1];
      final outputTensors = _interpreter!.getOutputTensors();
      outputShapes = [];
      _outputTypes = [];
      for (final tensor in outputTensors) {
        outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      }
    } on Exception catch (e) {
      logger.warning(e.toString());
    }
  }

  /// image pre process
  TensorImage getProcessedImage(TensorImage inputImage) {
    final padSize = max(inputImage.height, inputImage.width);

    imageProcessor ??= ImageProcessorBuilder()
        .add(
      ResizeWithCropOrPadOp(
        padSize,
        padSize,
      ),
    )
        .add(
      ResizeOp(
        inputSize,
        inputSize,
        ResizeMethod.BILINEAR,
      ),
    )
        .build();
    return imageProcessor!.process(inputImage);
  }

  List<Recognition> predict(image_lib.Image image) {
    if (_interpreter == null) {
      return [];
    }

    var inputImage = TensorImage.fromImage(image);
    inputImage = getProcessedImage(inputImage);

    TfLiteType tensorType;
    List<int> shape = [inputSize, inputSize, 3];
    var normalizedTensorBuffer = TensorBuffer.createDynamic(TfLiteType.float32);

    if ( _interpreter!.getInputTensors()[0].type == TfLiteType.uint8) {
      tensorType = TfLiteType.uint8;
      List<int> normalizedInputImage = [];
      for (var pixel in inputImage.tensorBuffer.getIntList()) {
        normalizedInputImage.add(pixel.toInt());
      }
      normalizedTensorBuffer = TensorBuffer.createDynamic(tensorType);
      normalizedTensorBuffer.loadList(normalizedInputImage, shape: shape);
    } else {
      tensorType = TfLiteType.float32;
      List<double> normalizedInputImage = [];
      for (var pixel in inputImage.tensorBuffer.getDoubleList()) {
        normalizedInputImage.add(pixel/255);
      }
      normalizedTensorBuffer = TensorBuffer.createDynamic(tensorType);
      normalizedTensorBuffer.loadList(normalizedInputImage, shape: shape);
    } 

    final inputs = [normalizedTensorBuffer.buffer];

    /// tensor for results of inference
    final List<TensorBufferFloat> outputLocations = List<TensorBufferFloat>.generate(
      outputShapes.length, (index) => TensorBufferFloat(outputShapes[index]),
    );

    final outputs = {
      for (int i = 0; i < outputLocations.length; i++) i: outputLocations[i].buffer,
    };
    
    _interpreter!.runForMultipleInputs(inputs, outputs);

    // outputsからByteBufferを取得し、Float32Listに変換する例
    Float32List boxesList = outputs[0]!.asFloat32List();
    Float32List classIdsList = outputs[1]!.asFloat32List();
    Float32List scoresList = outputs[2]!.asFloat32List();
    Float32List numDetectionsList = outputs[3]!.asFloat32List();

    // Float32Listから必要なデータを取得する
    int numDetections = numDetectionsList[0].toInt();

    List<Recognition> recognitions = [];
    for (int i = 0; i < numDetections; i++) {
      double y = boxesList[i * 4 + 0];
      double x = boxesList[i * 4 + 1];
      double h = boxesList[i * 4 + 2] - y;
      double w = boxesList[i * 4 + 3] - x;
      Rect rect = Rect.fromLTWH(x*inputSize, y*inputSize, w*inputSize, h*inputSize);
      Rect transformRect = imageProcessor!.inverseTransformRect(rect, image.height, image.width);
      if(scoresList[i] < objConfTh) continue;
      recognitions.add(Recognition(i, classIdsList[i].toInt(), scoresList[i], transformRect));
    }
    return recognitions;
  }
}