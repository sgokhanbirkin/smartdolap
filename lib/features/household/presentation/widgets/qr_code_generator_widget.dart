import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// QR code generator widget - Displays QR code for invite code
class QrCodeGeneratorWidget extends StatelessWidget {
  /// QR code generator widget constructor
  const QrCodeGeneratorWidget({
    super.key,
    required this.inviteCode,
    this.size,
  });

  /// Invite code to encode
  final String inviteCode;

  /// Size of the QR code
  final double? size;

  @override
  Widget build(BuildContext context) {
    final double qrSize = size ?? 200.w;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: QrImageView(
        data: inviteCode,
        version: QrVersions.auto,
        size: qrSize,
        backgroundColor: Colors.white,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      ),
    );
  }
}

