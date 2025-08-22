import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _webViewController;
  final RampConfig config;
  final RampCallbacks callbacks;

  ZBDRampController({
    required this.config,
    required this.callbacks,
  }) {
    print('ZBDRampController: Initializing with session token: ${config.sessionToken.substring(0, 20)}...');
    _initializeController();
  }

  WebViewController get webViewController => _webViewController;

  void _initializeController() {
    print('ZBDRampController: Starting controller initialization');
    
    _webViewController = WebViewController();
    print('WebViewController created');
    
    _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    print('JavaScript mode set');
    
    _webViewController.setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Mobile Safari/537.36');
    print('User agent set');
    
    _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) {
          print('✅ WebView finished loading: $url');
        },
        onPageStarted: (String url) {
          print('🔄 WebView started loading: $url');
        },
        onWebResourceError: (WebResourceError error) {
          print('❌ WebView resource error: ${error.description} - ${error.errorCode}');
        },
        onNavigationRequest: (NavigationRequest request) {
          print('📍 Navigation request: ${request.url}');
          return NavigationDecision.navigate;
        },
      ),
    );
    print('NavigationDelegate set');

    final String widgetUrl;
    if (config.widgetUrl != null) {
      widgetUrl = config.widgetUrl!;
      print('Using API-provided widget URL: $widgetUrl');
    } else {
      final baseUrl = UrlBuilder.getWidgetUrl(config.environment);
      widgetUrl = UrlBuilder.buildWidgetUrl(
        baseUrl: baseUrl,
        sessionToken: config.sessionToken,
        secret: config.secret,
      );
      print('Building widget URL: $widgetUrl');
    }
    
    print('About to load URL: $widgetUrl');
    
    try {
      // Test with a very simple HTML first
      print('🧪 Testing with simple HTML...');
      _webViewController.loadHtmlString('<html><body><h1>Test HTML</h1></body></html>');
      
      // After 3 seconds, try loading Google
      Future.delayed(Duration(seconds: 3), () {
        print('🧪 Now testing with Google...');
        _webViewController.loadRequest(Uri.parse('https://www.google.com'));
      });
      
      // After 8 seconds, load the actual widget URL
      Future.delayed(Duration(seconds: 8), () {
        print('🎯 Now loading widget URL...');
        final uri = Uri.parse(widgetUrl);
        _webViewController.loadRequest(uri);
      });
      
    } catch (e) {
      print('❌ Error in initialization: $e');
    }
  }

  void _onPageFinished(String url) {
    print('WebView finished loading: $url');
    // Widget is ready - no additional configuration needed
    // All configuration is handled via the session token
  }

  void _handleMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
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
    _webViewController.runJavaScript('''
      if (window.ZBDRampChannel) {
        window.ZBDRampChannel.postMessage('$messageJson');
      }
    ''');
  }

  void updateConfig(RampConfig newConfig) {
    // Configuration updates would require a new session token
    // For now, we recommend creating a new widget instance
    if (kDebugMode) {
      print('Configuration updates require a new session token. Create a new widget instance.');
    }
  }

  void reload() {
    _webViewController.reload();
  }
}