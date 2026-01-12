import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class SimpleBarcodeScannerPage extends StatefulWidget {
  const SimpleBarcodeScannerPage({super.key});

  @override
  State<SimpleBarcodeScannerPage> createState() =>
      _SimpleBarcodeScannerPageState();
}

class _SimpleBarcodeScannerPageState extends State<SimpleBarcodeScannerPage> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('scan_barcode'.tr()),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
    body: MobileScanner(
      onDetect: (BarcodeCapture capture) {
        if (_isScanned) {
          return;
        }
        final List<Barcode> barcodes = capture.barcodes;
        for (final Barcode barcode in barcodes) {
          if (barcode.rawValue != null) {
            _isScanned = true;
            Navigator.of(context).pop(barcode.rawValue);
            break;
          }
        }
      },
    ),
  );
}
