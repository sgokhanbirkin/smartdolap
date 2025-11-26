import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// QR code scanner widget - Scans QR codes for invite codes
class QrCodeScannerWidget extends StatefulWidget {
  /// QR code scanner widget constructor
  const QrCodeScannerWidget({
    required this.onCodeScanned, super.key,
  });

  /// Callback when QR code is scanned
  final ValueChanged<String> onCodeScanned;

  @override
  State<QrCodeScannerWidget> createState() => _QrCodeScannerWidgetState();
}

class _QrCodeScannerWidgetState extends State<QrCodeScannerWidget> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod Tara'),
      ),
      body: Stack(
        children: <Widget>[
          MobileScanner(
            controller: _controller,
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final Barcode barcode in barcodes) {
                if (barcode.rawValue != null) {
                  widget.onCodeScanned(barcode.rawValue!);
                  Navigator.of(context).pop();
                  break;
                }
              }
            },
          ),
          // Overlay with scanning area
          Center(
            child: Container(
              width: 250.w,
              height: 250.w,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 3.w,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 50.h,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16.w),
              margin: EdgeInsets.symmetric(horizontal: 32.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                'QR kodu tarayın',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
}

