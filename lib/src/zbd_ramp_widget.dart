import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'models/ramp_config.dart';
import 'models/ramp_callbacks.dart';
import 'zbd_ramp_controller.dart';

class ZBDRampWidget extends StatefulWidget {
  final RampConfig config;
  final RampCallbacks callbacks;
  final double? width;
  final double? height;

  const ZBDRampWidget({
    Key? key,
    required this.config,
    required this.callbacks,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<ZBDRampWidget> createState() => _ZBDRampWidgetState();
}

class _ZBDRampWidgetState extends State<ZBDRampWidget> {
  late final ZBDRampController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ZBDRampController(
      config: widget.config,
      callbacks: widget.callbacks,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget webView = WebViewWidget(
      controller: _controller.webViewController,
    );

    if (widget.width != null || widget.height != null) {
      webView = SizedBox(
        width: widget.width,
        height: widget.height,
        child: webView,
      );
    }

    return webView;
  }

  void updateConfig(RampConfig newConfig) {
    _controller.updateConfig(newConfig);
  }

  void sendMessage(PostMessageData message) {
    _controller.sendMessage(message);
  }

  void reload() {
    _controller.reload();
  }
}