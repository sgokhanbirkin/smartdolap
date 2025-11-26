// ignore_for_file: public_member_api_docs

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';

/// Offline indicator widget
/// Shows a banner when device is offline
/// Follows SOLID principles - Single Responsibility
class OfflineIndicator extends StatefulWidget {
  /// Offline indicator constructor
  const OfflineIndicator({required this.child, super.key});

  final Widget child;

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final bool isOffline = results.every((ConnectivityResult r) => r == ConnectivityResult.none);
      if (_isOffline != isOffline) {
        setState(() {
          _isOffline = isOffline;
        });
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    final bool isOffline = results.every((ConnectivityResult r) => r == ConnectivityResult.none);
    if (mounted) {
      setState(() {
        _isOffline = isOffline;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
      // Use non-directional alignment to avoid requiring Directionality widget
      alignment: Alignment.topLeft,
      children: <Widget>[
        widget.child,
        if (_isOffline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.padding,
                  vertical: AppSizes.spacingS,
                ),
                color: Theme.of(context).colorScheme.errorContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.wifi_off,
                      size: AppSizes.iconS,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    SizedBox(width: AppSizes.spacingS),
                    Text(
                      tr('offline_indicator'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: AppSizes.textS,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
}

