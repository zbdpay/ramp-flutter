import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

import 'models/ramp_config.dart';
import 'models/ramp_callbacks.dart';
import 'models/ramp_error.dart';
import 'models/ramp_log.dart';
import 'utils/url_builder.dart';

class PostMessageData {
  final String type;
  final dynamic payload;

  const PostMessageData({
    required this.type,
    this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'payload': payload,
    };
  }

  factory PostMessageData.fromJson(Map<String, dynamic> json) {
    return PostMessageData(
      type: json['type'],
      payload: json['payload'],
    );
  }
}

class ZBDRampController {
  InAppWebViewController? _webViewController;
  final RampConfig config;
  final RampCallbacks callbacks;
  bool _isInitialized = false;
  VoidCallback? onInitialized;

  ZBDRampController({
    required this.config,
    required this.callbacks,
    this.onInitialized,
  }) {
    print(
        'ZBDRampController: Initializing with session token: ${config.sessionToken.substring(0, 20)}...');
    _requestPermissionsAndInitialize();
  }

  InAppWebViewController? get webViewController => _webViewController;
  bool get isInitialized => _isInitialized;

  Future<void> _requestPermissionsAndInitialize() async {
    print('🔐 Requesting camera and audio permissions...');

    try {
      final Map<Permission, PermissionStatus> permissions = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      print('📷 Camera permission: ${permissions[Permission.camera]}');
      print('🎤 Microphone permission: ${permissions[Permission.microphone]}');

      _isInitialized = true;
      print('✅ ZBDRampController initialization completed');
      onInitialized?.call();
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      _isInitialized = true;
      onInitialized?.call();
    }
  }

  InAppWebViewSettings get initialSettings => InAppWebViewSettings(
    useShouldOverrideUrlLoading: false,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
    javaScriptEnabled: true,
    domStorageEnabled: true,
    databaseEnabled: true,
    userAgent: 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Mobile Safari/537.36',
  );

  void onWebViewCreated(InAppWebViewController controller) {
    _webViewController = controller;
    print('✅ InAppWebView created');

    _webViewController!.addJavaScriptHandler(
      handlerName: 'ZBDRampChannel',
      callback: (args) {
        if (args.isNotEmpty) {
          _handleMessage(args[0].toString());
        }
      },
    );

    final String widgetUrl = _buildWidgetUrl();
    print('📍 Loading widget URL: $widgetUrl');

    _webViewController!.loadUrl(
      urlRequest: URLRequest(url: WebUri(widgetUrl)),
    );
  }

  String _buildWidgetUrl() {
    if (config.widgetUrl != null) {
      print('Using API-provided widget URL: ${config.widgetUrl}');
      return config.widgetUrl!;
    } else {
      final baseUrl = UrlBuilder.getWidgetUrl(config.environment);
      final widgetUrl = UrlBuilder.buildWidgetUrl(
        baseUrl: baseUrl,
        sessionToken: config.sessionToken,
        secret: config.secret,
      );
      print('Building widget URL: $widgetUrl');
      return widgetUrl;
    }
  }

  Future<PermissionResponse?> onPermissionRequest(InAppWebViewController controller, PermissionRequest request) async {
    print('📷 WebView permission request for origin: ${request.origin}');
    print('📷 Resources requested: ${request.resources}');

    final resources = <PermissionResourceType>[];

    for (final resource in request.resources) {
      if (resource == PermissionResourceType.CAMERA ||
          resource == PermissionResourceType.MICROPHONE) {
        resources.add(resource);
        print('✅ Granting permission for: $resource');
      }
    }

    return PermissionResponse(
      resources: resources,
      action: PermissionResponseAction.GRANT,
    );
  }

  void onLoadStart(InAppWebViewController controller, WebUri? url) {
    print('🔄 WebView started loading: $url');
  }

  void onLoadStop(InAppWebViewController controller, WebUri? url) {
    print('✅ WebView finished loading: $url');

    controller.evaluateJavascript(source: '''
      console.log('🔍 Testing camera permissions...');

      if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
        console.log('✅ getUserMedia is available');

        navigator.permissions.query({name: 'camera'}).then(function(result) {
          console.log('📷 Camera permission status: ' + result.state);
          window.flutter_inappwebview.callHandler('ZBDRampChannel', JSON.stringify({
            type: 'CAMERA_PERMISSION_STATUS',
            payload: { status: result.state }
          }));
        }).catch(function(error) {
          console.log('❌ Permission query failed:', error);
        });

        navigator.mediaDevices.getUserMedia({ video: true })
          .then(function(stream) {
            console.log('✅ Camera access granted');
            stream.getTracks().forEach(track => track.stop());
            window.flutter_inappwebview.callHandler('ZBDRampChannel', JSON.stringify({
              type: 'CAMERA_TEST_SUCCESS',
              payload: { message: 'Camera access successful' }
            }));
          })
          .catch(function(error) {
            console.log('❌ Camera access failed:', error.name, error.message);
            window.flutter_inappwebview.callHandler('ZBDRampChannel', JSON.stringify({
              type: 'CAMERA_TEST_ERROR',
              payload: {
                name: error.name,
                message: error.message,
                code: error.code || 'unknown'
              }
            }));
          });
      } else {
        console.log('❌ getUserMedia not available');
        window.flutter_inappwebview.callHandler('ZBDRampChannel', JSON.stringify({
          type: 'CAMERA_TEST_ERROR',
          payload: { message: 'getUserMedia not available' }
        }));
      }
    ''');
  }

  void onReceivedError(InAppWebViewController controller, WebResourceRequest request, WebResourceError error) {
    print('❌ WebView resource error: ${error.description} - ${error.type}');
  }

  void _handleMessage(String message) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final postMessage = PostMessageData.fromJson(data);

      switch (postMessage.type) {
        case 'WIDGET_SUCCESS':
          callbacks.onSuccess?.call(postMessage.payload);
          break;

        case 'WIDGET_ERROR':
          final error = RampError.fromJson(postMessage.payload ?? {});
          callbacks.onError?.call(error);
          break;

        case 'WIDGET_STEP_CHANGE':
          final step = postMessage.payload?['step'] as String? ?? '';
          callbacks.onStepChange?.call(step);
          break;

        case 'WIDGET_LOG':
          final log = RampLog.fromJson(postMessage.payload ?? {});
          callbacks.onLog?.call(log);
          break;

        case 'WIDGET_READY':
          callbacks.onReady?.call();
          break;

        case 'WIDGET_CLOSE':
          callbacks.onClose?.call();
          break;

        default:
          if (kDebugMode) {
            print('Unknown message type from widget: ${postMessage.type}');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to parse message from widget: $e');
      }
    }
  }

  void sendMessage(PostMessageData message) {
    final messageJson = jsonEncode(message.toJson());
    _webViewController?.evaluateJavascript(source: '''
      if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
        window.flutter_inappwebview.callHandler('ZBDRampChannel', '$messageJson');
      }
    ''');
  }

  void updateConfig(RampConfig newConfig) {
    if (kDebugMode) {
      print(
          'Configuration updates require a new session token. Create a new widget instance.');
    }
  }

  void reload() {
    _webViewController?.reload();
  }
}
