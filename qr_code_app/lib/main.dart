import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code 3D Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainMenu(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menu Principal")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => QRScannerPage()));
          },
          child: Text("SCANEAR QR CODE"),
        ),
      ),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    ctrl.scannedDataStream.listen((scanData) {
      if (scannedData == null) {
        setState(() {
          scannedData = scanData.code;
        });
        controller?.pauseCamera();
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
    if (scannedData != null) {
      return ModelViewerScreen(modelUrl: scannedData!);
    }

    return Scaffold(
      appBar: AppBar(title: Text('QR Code Scanner')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }
}

class ModelViewerScreen extends StatelessWidget {
  final String modelUrl;

  const ModelViewerScreen({required this.modelUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modelo 3D')),
      body: ModelViewer(
        src: modelUrl, // Exemplo: "https://modelos.com/modelo.glb"
        alt: "Modelo escaneado",
        ar: true,
        autoRotate: true,
        cameraControls: true,
        backgroundColor: Colors.white,
      ),
    );
  }
}
