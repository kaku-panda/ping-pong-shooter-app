// MLCameraManager.dart

import 'package:flutter/widgets.dart';
import 'package:camera/camera.dart';
import 'package:flutter_yolov5_app/data/model/ml_camera.dart';
import 'package:flutter_yolov5_app/screens/ar.dart';

class ArPluginProvider extends ChangeNotifier {

  GlobalKey<AugmentedRearityScreenState> _arViewKey = GlobalKey();

  get arViewKey => _arViewKey;

  ArPluginProvider() {}

  resetARView() {
    _arViewKey = GlobalKey();
    notifyListeners();
  }
}