import 'dart:typed_data';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: true,
  );
  String? barcodeValue;

  @override
  void initState() {
    super.initState();
     _requestCameraPermission();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const CustomSnackbar(),
      );
    });
  }

  Future<void> _requestCameraPermission() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    await Permission.camera.request();
  }
}

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller.start();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              _handleQrDetection(capture);
            },
          ),
          Center(
            child: CustomPaint(
              size: const Size(250, 250),
              painter: SmoothRoundedPainter(),
            ),
          ),
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Point QR Code into the box",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Handle QR Code detection
  void _handleQrDetection(BarcodeCapture capture) {
    final Uint8List? image = capture.image;
    final List<Barcode> value = capture.barcodes;

    for (final barcode in value) {
      barcodeValue = barcode.rawValue!;
    }
    if (image != null && barcodeValue != null) {
      _controller.stop(); // Pause scanning
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("QR Code Detected"),
              const SizedBox(height: 10),
              Image.memory(image),
              Text(barcodeValue!, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              // Close and Copy buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Copy button
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: barcodeValue!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.copy),
                        Text("Copy"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Close button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _controller.start(); // Resume scanning
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.close),
                        Text("Close"),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }
  }
}

// Painter dan Snackbar tetap sama seperti sebelumnya
class SmoothRoundedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path();
    const double cornerSize = 20;

    // Sudut kiri atas
    path.moveTo(0, cornerSize);
    path.lineTo(0, 0);
    path.lineTo(cornerSize, 0);

    // Sudut kanan atas
    path.moveTo(size.width - cornerSize, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, cornerSize);

    // Sudut kiri bawah
    path.moveTo(0, size.height - cornerSize);
    path.lineTo(0, size.height);
    path.lineTo(cornerSize, size.height);

    // Sudut kanan bawah
    path.moveTo(size.width - cornerSize, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height - cornerSize);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// snackbar kustom untuk informasi tambahan.
class CustomSnackbar extends StatelessWidget {
  const CustomSnackbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Scan QR Code",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Place QR code inside the frame to scan. Please avoid shake to get results quickly.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Center(
            child: Image.asset(
              'assets/images/scan-icon.png',
              width: 220,
              height: 220,
            ),
          ),
        ],
      ),
    );
  }
}
