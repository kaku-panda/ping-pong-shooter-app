import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_yolov5_app/components/style.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class ARScreen extends ConsumerStatefulWidget {
  const ARScreen({Key? key}) : super(key: key);
  @override
  ARScreenState createState() => ARScreenState();
}

class ARScreenState extends ConsumerState<ARScreen> {
  
  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UnityWidgetController? _unityWidgetController;
  double _sliderValue = 0.0;

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


    return Scaffold(
      appBar: AppBar(
        title: Text('AR', style: Styles.defaultStyle18),
      ),
      body: UnityWidget(
        onUnityCreated: onUnityCreated,
        onUnityMessage: onUnityMessage,
        onUnitySceneLoaded: onUnitySceneLoaded,
        fullscreen: false,
      ),
    );
  }

  // Communcation from Flutter to Unity
  void setRotationSpeed(String speed) {
    _unityWidgetController?.postMessage(
      'CubeManager',
      'SetRotationSpeed',
      speed,
    );
  }

  // Communication from Unity to Flutter
  void onUnityMessage(message) {
    print('Received message from unity: ${message.toString()}');
  }

  // Callback that connects the created controller to the unity controller
  void onUnityCreated(controller) {
    _unityWidgetController = controller;
  }

  // Communication from Unity when new scene is loaded to Flutter
  void onUnitySceneLoaded(SceneLoaded? sceneInfo) {
    if (sceneInfo != null) {
      print('Received scene loaded from unity: ${sceneInfo.name}');
      print(
          'Received scene loaded from unity buildIndex: ${sceneInfo.buildIndex}');
    }
  }
}
