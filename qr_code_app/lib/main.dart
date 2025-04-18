import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu Principal")),
      body: Center(
        child: ElevatedButton(
          child: const Text("SCANEAR QR CODE"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QRScannerScreen()),
            );
          },
        ),
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanned = false;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!scanned) {
        setState(() => scanned = true);
        controller.pauseCamera();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ARViewScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }
}

class ARViewScreen extends StatefulWidget {
  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Visualizador 3D")),
      body: ARView(
        onARViewCreated: onARViewCreated,  // A função agora recebe ARViewController
      ),
    );
  }

  void onARViewCreated(ARViewController arViewController) {
    final arSessionManager = arViewController.sessionManager;
    final arObjectManager = arViewController.objectManager;

    arSessionManager.onInitialize().then((_) {
      arObjectManager.onInitialize().then((_) {
        final node = ARNode(
          type: NodeType.localGLTF2,
          uri: "assets/models/modelo.glb",
          scale: Vector3(0.5, 0.5, 0.5),
          position: Vector3(0.0, 0.0, -1.0),
          rotation: Vector4(0.0, 0.0, 0.0, 1.0),
        );

        arObjectManager.addNode(node);
      });
    });
  }
}
