import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

const Color primaryColor = Color(0xFF3A2EC3);
const List<Color> qrColors = [
  Colors.white,
  Colors.grey,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.cyan,
  Colors.purple,
];

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final List<String> _qrTypes = ['JPG', 'PNG', 'SVG', 'PDF'];

  String? _qrData;
  Color _qrColor = Colors.white;
  String? _selectedQrType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(height: 200, color: primaryColor),
              Expanded(child: Container(color: Colors.white)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: _boxDecoration(),
                    child: Column(
                      children: [
                        _QrCodeDisplay(
                          screenshotController: _screenshotController,
                          qrData: _qrData,
                          qrColor: _qrColor,
                        ),
                        const SizedBox(height: 25),
                        _buildLinkTextField(),
                        const SizedBox(height: 20),
                        _buildQrTypeDropdown(),
                        const SizedBox(height: 30),
                        _ColorPicker(
                          colors: qrColors,
                          selectedColor: _qrColor,
                          onColorSelected: (color) {
                            setState(() {
                              _qrColor = color;
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        const Divider(),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _buildLinkTextField() {
    return TextField(
      decoration: const InputDecoration(
        labelText: "Link",
        hintText: "Insert link here...",
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {
          _qrData = value;
        });
      },
    );
  }

  Widget _buildQrTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "QR Code Type",
        border: OutlineInputBorder(),
      ),
      value: _selectedQrType,
      hint: const Text('Select QR Code Type'),
      items: _qrTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedQrType = value;
        });
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _cancel,
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          width: 1,
          color: Colors.grey.shade300,
          height: 50,
        ),
        Expanded(
          child: TextButton(
            onPressed: _shareQrCode,
            child: const Text(
              "Share",
              style: TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _cancel() {
    setState(() {
      _qrData = null;
      _selectedQrType = null;
    });
  }

  Future<void> _shareQrCode() async {
    final image = await _screenshotController.capture();
    if (image != null) {
      await Share.shareXFiles([
        XFile.fromData(
          image,
          name: "qr_code.png",
          mimeType: "image/png",
        ),
      ]);
    }
  }
}

class _QrCodeDisplay extends StatelessWidget {
  const _QrCodeDisplay({
    Key? key,
    required this.screenshotController,
    required this.qrData,
    required this.qrColor,
  }) : super(key: key);

  final ScreenshotController screenshotController;
  final String? qrData;
  final Color qrColor;

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: qrData == null || qrData!.isEmpty
            ? const Text(
                "No QR Code Generated",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              )
            : Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: qrColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: PrettyQr(
                  data: qrData!,
                  size: 150,
                  roundEdges: true,
                  elementColor: Colors.black,
                ),
              ),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    Key? key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  }) : super(key: key);

  final List<Color> colors;
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedColor == color ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}