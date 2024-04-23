////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


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
    screenSize = Size(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("AR"),
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          Positioned(
            top: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: () {
                onArSessionMangerInitialize();
                setState(() {});
              },
              child: const Text("Initialize AR"),
            ),
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
  }


  void onArSessionMangerInitialize() {
    arSessionManager!.onInitialize(
      showFeaturePoints: true,
      showPlanes: true,
      customPlaneTexturePath: "assets/images/triangle.png",
      showWorldOrigin: true,
      handleTaps: true,
    );
  }
}