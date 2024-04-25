////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:collection/collection.dart';
import 'dart:math' as math;


class AugmentedRearityScreen extends ConsumerStatefulWidget {
  const AugmentedRearityScreen({Key? key}) : super(key: key);
  @override
  AugmentedRearityScreenState createState() => AugmentedRearityScreenState();
}

class AugmentedRearityScreenState extends ConsumerState<AugmentedRearityScreen> {
  late ARKitController arkitController;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Physics Sample')),
      body: Container(
          child: ARKitSceneView(onARKitViewCreated: onARKitViewCreated)));

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;

    _addPlane(this.arkitController);
    _addSphere(this.arkitController);
  }

  void _addSphere(ARKitController controller) {
    final material =
        ARKitMaterial(diffuse: ARKitMaterialProperty.color(Colors.blue));
    final sphere = ARKitSphere(materials: [material], radius: 0.1);
    final node = ARKitNode(
        geometry: sphere,
        physicsBody: ARKitPhysicsBody(
          ARKitPhysicsBodyType.dynamicType,
          categoryBitMask: BodyType.sphere.index + 1,
        ),
        position: vector.Vector3(0, 1, -1));
    controller.add(node);
  }

  void _addPlane(ARKitController controller) {
    final plane = ARKitPlane(
      width: 2,
      height: 2,
      materials: [
        ARKitMaterial(
          diffuse: ARKitMaterialProperty.color(Colors.green),
        )
      ],
    );
    final node = ARKitNode(
      geometry: plane,
      physicsBody: ARKitPhysicsBody(
        ARKitPhysicsBodyType.staticType,
        shape: ARKitPhysicsShape(plane),
        categoryBitMask: BodyType.plane.index + 1,
      ),
      rotation: vector.Vector4(1, 0, 0, -math.pi / 2),
      position: vector.Vector3(0, -0.5, -1),
    );
    controller.add(node);
  }
}
enum BodyType { sphere, plane }