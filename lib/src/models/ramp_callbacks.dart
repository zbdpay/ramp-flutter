import 'ramp_error.dart';
import 'ramp_log.dart';

typedef OnSuccessCallback = void Function(dynamic data);
typedef OnErrorCallback = void Function(RampError error);
typedef OnStepChangeCallback = void Function(String step);
typedef OnLogCallback = void Function(RampLog log);
typedef OnReadyCallback = void Function();
typedef OnCloseCallback = void Function();

class RampCallbacks {
  final OnSuccessCallback? onSuccess;
  final OnErrorCallback? onError;
  final OnStepChangeCallback? onStepChange;
  final OnLogCallback? onLog;
  final OnReadyCallback? onReady;
  final OnCloseCallback? onClose;

  const RampCallbacks({
    this.onSuccess,
    this.onError,
    this.onStepChange,
    this.onLog,
    this.onReady,
    this.onClose,
  });
}
