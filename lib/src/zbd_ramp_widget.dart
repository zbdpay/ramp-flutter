import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
      callbacks: widget.callbacks.copyWith(
        onCreateWindow: _handleCreateWindow,
      ),
      onInitialized: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  void _handleCreateWindow(CreateWindowAction createWindowAction) {
    print("Creating full-screen popup window for OAuth");

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              title: Text('Bank Authentication'),
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: InAppWebView(
              // Setting the windowId property is important here!
              windowId: createWindowAction.windowId,
              initialSettings: _controller.initialSettings,
              onWebViewCreated: (InAppWebViewController controller) {
                print("OAuth popup WebView created");
              },
              onLoadStart: (InAppWebViewController controller, WebUri? url) {
                print("OAuth popup onLoadStart: $url");
              },
              onLoadStop: (InAppWebViewController controller, WebUri? url) {
                print("OAuth popup onLoadStop: $url");
              },
              onCloseWindow: (InAppWebViewController controller) {
                print("OAuth popup onCloseWindow called");
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isInitialized) {
      return Container(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Requesting permissions...'),
            ],
          ),
        ),
      );
    }

    Widget webView = InAppWebView(
      initialSettings: _controller.initialSettings,
      onWebViewCreated: _controller.onWebViewCreated,
      onPermissionRequest: _controller.onPermissionRequest,
      onLoadStart: _controller.onLoadStart,
      onLoadStop: _controller.onLoadStop,
      onReceivedError: _controller.onReceivedError,
      onCreateWindow: _controller.onCreateWindow,
      onCloseWindow: _controller.onCloseWindow,
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
