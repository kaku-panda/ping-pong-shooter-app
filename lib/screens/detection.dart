import 'package:flutter/material.dart';
import 'package:flutter_yolov5_app/components/button.dart';
import 'package:flutter_yolov5_app/components/modal_window.dart';
import 'package:flutter_yolov5_app/components/style.dart';
import 'package:flutter_yolov5_app/main.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:camera/camera.dart';

import 'package:flutter_yolov5_app/data/entity/recognition.dart';

class DetectionScreen extends ConsumerStatefulWidget {
  const DetectionScreen({Key? key}) : super(key: key);
  @override
  DetectionScreenState createState() => DetectionScreenState();
}

class DetectionScreenState extends ConsumerState<DetectionScreen> {

  final List<String> modelList = [
    'coco128_float32.tflite',
    'yolov5n_float32.tflite',
    'yolov5s_float32.tflite',
    'yolov5m_float32.tflite',
    'yolov5l_float32.tflite',
    'ssd_mobilenet_uint8.tflite',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  } 

  @override
  Widget build(BuildContext context) {
    
    final size         = MediaQuery.of(context).size;
    final mlCamera     = ref.watch(mlCameraProvider).camera;
    final useGpu       = ref.watch(settingProvider).useGPU;
    final modelName    = ref.watch(settingProvider).modelName;
    final isStop       = ref.watch(settingProvider).isStop;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detection', style: Styles.defaultStyle18),
      ),
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child:
            FittedBox(
              fit: BoxFit.fitHeight,
              alignment: Alignment.center,
              child: SizedBox(
                width: 480,
                height: 640,
                child:
                  Stack(
                    children: [
                      CameraView(
                        cameraController: mlCamera.cameraController
                      ),
                      buildBoxes(
                        ref.watch(mlCameraProvider).camera.recognitions,
                        Size(
                          mlCamera.actualPreviewSize.width * ((size.height-56-AppBar().preferredSize.height-MediaQuery.of(context).padding.top) / mlCamera.actualPreviewSize.height),
                          (size.height-56-AppBar().preferredSize.height-MediaQuery.of(context).padding.top)
                        ),
                        mlCamera.ratio,
                      ),
                    ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomTextButton(
                      text: 'Use GPU',
                      backgroundColor: Styles.darkBgColor,
                      enable: useGpu,
                      width: 80,
                      height: 30,
                      onPressed: () async {
                        ref.read(settingProvider).useGPU = !useGpu;
                        ref.read(settingProvider).storePreferences();
                        mlCamera.changeModel(!useGpu, modelName);
                      }
                    ),
                    CustomTextButton(
                      text: 'STOP',
                      backgroundColor: Styles.darkBgColor,
                      enable: isStop,
                      width: 80,
                      height: 30,
                      onPressed: () async {
                        ref.read(settingProvider).isStop = !isStop;
                        ref.read(settingProvider).storePreferences();
                        mlCamera.stopDetection(!isStop);
                      }
                    ),
                    CustomTextButton(
                      text: modelName,
                      backgroundColor: Styles.darkBgColor,
                      enable: true,
                      width: 200,
                      height: 30,
                      onPressed: (){
                        showModalWindow(
                          context,
                          0.5,
                          buildModalWindowContainer(
                            context,
                            [
                            for (var model in modelList)
                              Text(
                                model,
                                style: Styles.headlineStyle13,
                                textAlign: TextAlign.center,
                              ),
                            ],
                            0.5,
                            (BuildContext context, int index) {
                              ref.read(settingProvider).modelName = modelList[index];
                              ref.read(settingProvider).storePreferences();
                              mlCamera.changeModel(!useGpu, modelList[index]);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: Text("${(ref.watch(mlCameraProvider).camera.elapsed == 0 ? 0 : 1000 / ref.watch(mlCameraProvider).camera.elapsed).toStringAsFixed(2)} FPS", style: Styles.defaultStyle18),
                    ),
                    Text("  (${ref.watch(mlCameraProvider).camera.elapsed} ms)", style: Styles.defaultStyle18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBoxes(
      List<Recognition> recognitions,
      Size actualPreviewSize,
      double ratio,
      ) {
    if (recognitions.isEmpty) {
      return const SizedBox();
    }
    return Stack(
      children: recognitions.map((result) {
        return BoundingBox(
          result: result,
          actualPreviewSize: actualPreviewSize,
          ratio: ratio,
        );
      }).toList(),
    );
  }
}

class CameraView extends StatelessWidget {
  const CameraView({
    Key? key,
    required this.cameraController,
  }) : super(key: key);
  final CameraController cameraController;
  @override
  Widget build(BuildContext context) {
    return
    CameraPreview(
      cameraController
    );
  }
}

class BoundingBox extends StatelessWidget {
  const BoundingBox({
    Key? key,
    required this.result,
    required this.actualPreviewSize,
    required this.ratio,
  }) : super(key: key);
  final Recognition result;
  final Size actualPreviewSize;
  final double ratio;
  @override
  Widget build(BuildContext context) {

    final renderLocation = result.getRenderLocation(
      actualPreviewSize,
      ratio,
    );
    return Positioned(
      left: renderLocation.left,
      top: renderLocation.top,
      width: renderLocation.width,
      height: renderLocation.height,
      child: Container(
        width: renderLocation.width,
        height: renderLocation.height,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.primaries[
              result.label % Colors.primaries.length
            ],
            width: 3,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(2),
          ),
        ),
        child: buildBoxLabel(result, context),
      ),
    );
  }

  Align buildBoxLabel(Recognition result, BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: FittedBox(
        child: ColoredBox(
          color: Colors.primaries[
            result.label % Colors.primaries.length
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result.displayLabel,
              ),
              Text(
                ' ${result.score.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
