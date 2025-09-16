import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'ramp_error.dart';
import 'ramp_log.dart';

typedef OnSuccessCallback = void Function(dynamic data);
typedef OnErrorCallback = void Function(RampError error);
typedef OnStepChangeCallback = void Function(String step);
typedef OnLogCallback = void Function(RampLog log);
typedef OnReadyCallback = void Function();
typedef OnCloseCallback = void Function();
typedef OnCreateWindowCallback = void Function(CreateWindowAction createWindowAction);

class RampCallbacks {
  final OnSuccessCallback? onSuccess;
  final OnErrorCallback? onError;
  final OnStepChangeCallback? onStepChange;
  final OnLogCallback? onLog;
  final OnReadyCallback? onReady;
  final OnCloseCallback? onClose;
  final OnCreateWindowCallback? onCreateWindow;

  const RampCallbacks({
    this.onSuccess,
    this.onError,
    this.onStepChange,
    this.onLog,
    this.onReady,
    this.onClose,
    this.onCreateWindow,
  });

  RampCallbacks copyWith({
    OnSuccessCallback? onSuccess,
    OnErrorCallback? onError,
    OnStepChangeCallback? onStepChange,
    OnLogCallback? onLog,
    OnReadyCallback? onReady,
    OnCloseCallback? onClose,
    OnCreateWindowCallback? onCreateWindow,
  }) {
    return RampCallbacks(
      onSuccess: onSuccess ?? this.onSuccess,
      onError: onError ?? this.onError,
      onStepChange: onStepChange ?? this.onStepChange,
      onLog: onLog ?? this.onLog,
      onReady: onReady ?? this.onReady,
      onClose: onClose ?? this.onClose,
      onCreateWindow: onCreateWindow ?? this.onCreateWindow,
    );
  }
}
