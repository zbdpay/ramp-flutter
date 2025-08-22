enum LogLevel { info, warn, error, debug }

class RampLog {
  final LogLevel level;
  final String message;
  final dynamic data;

  const RampLog({
    required this.level,
    required this.message,
    this.data,
  });

  factory RampLog.fromJson(Map<String, dynamic> json) {
    final levelString = json['level'] as String? ?? 'info';
    final level = LogLevel.values.firstWhere(
      (e) => e.name == levelString,
      orElse: () => LogLevel.info,
    );

    return RampLog(
      level: level,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'message': message,
      'data': data,
    };
  }

  @override
  String toString() {
    return 'RampLog(level: ${level.name}, message: $message, data: $data)';
  }
}