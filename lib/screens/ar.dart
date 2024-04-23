////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'dart:async';

import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_yolov5_app/main.dart';
import 'package:vector_math/vector_math_64.dart';


class AugmentedRearityScreen extends ConsumerStatefulWidget {
  const AugmentedRearityScreen({Key? key}) : super(key: key);
  @override
  AugmentedRearityScreenState createState() => AugmentedRearityScreenState();
}

class AugmentedRearityScreenState extends ConsumerState<AugmentedRearityScreen> {
  
  Size screenSize = const Size(0, 0);

  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARNode? localObjectNode;
  ARNode? webObjectNode;
  ARNode? fileSystemNode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AR"),
      ),
      body: Stack(
        children: [
          ARView(
            key: ref.watch(arPluginProvider).arViewKey,
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
        ],
      ),
    );
  }
  
  void onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;

    this.arSessionManager!.onInitialize(
      showFeaturePoints: true,
      showPlanes: true,
      customPlaneTexturePath: "assets/images/triangle.png",
      showWorldOrigin: true,
      handleTaps: true,
    );
    this.arObjectManager!.onInitialize();

    this.arSessionManager!.onPlaneOrPointTap = this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTap;
  }

  Future<void> onLocalObjectAtOriginButtonPressed() async {
    if (localObjectNode != null) {
      arObjectManager!.removeNode(localObjectNode!);
      localObjectNode = null;
    } else {
      var newNode = ARNode(
          type: NodeType.localGLTF2,
          uri: "Models/Chicken_01/Chicken_01.gltf",
          scale: Vector3(0.02, 0.02, 0.02),
          position: Vector3(0.0, 0.0, 0.0),
          rotation: Vector4(1.0, 0.0, 0.0, 0.0));
      bool? didAddLocalNode = await arObjectManager!.addNode(newNode);
      localObjectNode = (didAddLocalNode!) ? newNode : null;
    }
  }

  void onPlaneOrPointTap(List<ARHitTestResult> hitResults) {
    if (hitResults.isNotEmpty) {
      ARHitTestResult firstResult = hitResults.first;

      // すでにノードが存在する場合は削除
      if (localObjectNode != null) {
        arObjectManager!.removeNode(localObjectNode!);
        localObjectNode = null;
      }

      // 新しいノードを作成し、タップされた位置に配置
      ARNode newNode = ARNode(
        type: NodeType.localGLTF2,
        uri: "Models/Chicken_01/Chicken_01.gltf",
        scale: Vector3(0.02, 0.02, 0.02),  // スケールは適宜調整
        position: firstResult.worldTransform.getTranslation(),  // タップした位置
        rotation: Vector4(1.0, 0.0, 0.0, 0.0)  // 回転は適宜調整
      );

      // ノードをARセッションに追加
      arObjectManager!.addNode(newNode).then((bool? didAddNode) {
        if (didAddNode!) {
          localObjectNode = newNode;  // 追加成功した場合は保存
          print("モデルをタップ位置に配置しました");
        } else {
          print("モデルの配置に失敗しました");
        }
      });
    } else {
      print("タップ位置が無効です");
    }
  }

}