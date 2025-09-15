class RampError {
  final String code;
  final String message;
  final dynamic details;

  const RampError({
    required this.code,
    required this.message,
    this.details,
  });

  factory RampError.fromJson(Map<String, dynamic> json) {
    return RampError(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'An error occurred',
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'details': details,
    };
  }

  @override
  String toString() {
    return 'RampError(code: $code, message: $message, details: $details)';
  }
}
