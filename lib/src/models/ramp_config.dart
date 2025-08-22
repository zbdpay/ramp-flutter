enum Environment { production, x1, x2, voltorb }

enum QuoteCurrency { USD }

enum BaseCurrency { BTC }

class RampConfig {
  final String sessionToken;
  final Environment environment;
  final String? secret;
  final String? widgetUrl;

  const RampConfig({
    required this.sessionToken,
    this.environment = Environment.production,
    this.secret,
    this.widgetUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionToken': sessionToken,
      'environment': environment.name,
      'secret': secret,
      'widgetUrl': widgetUrl,
    };
  }

  RampConfig copyWith({
    String? sessionToken,
    Environment? environment,
    String? secret,
    String? widgetUrl,
  }) {
    return RampConfig(
      sessionToken: sessionToken ?? this.sessionToken,
      environment: environment ?? this.environment,
      secret: secret ?? this.secret,
      widgetUrl: widgetUrl ?? this.widgetUrl,
    );
  }
}

class InitRampSessionConfig {
  final String apikey;
  final String email;
  final String destination;
  final QuoteCurrency quoteCurrency;
  final BaseCurrency baseCurrency;
  final String? webhookUrl;
  final String? referenceId;
  final Map<String, dynamic>? metadata;
  final Environment environment;

  const InitRampSessionConfig({
    required this.apikey,
    required this.email,
    required this.destination,
    this.quoteCurrency = QuoteCurrency.USD,
    this.baseCurrency = BaseCurrency.BTC,
    this.webhookUrl,
    this.referenceId,
    this.metadata,
    this.environment = Environment.production,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'destination': destination,
      'quote_currency': quoteCurrency.name,
      'base_currency': baseCurrency.name,
      'webhook_url': webhookUrl,
      'reference_id': referenceId,
      'metadata': metadata,
    };
  }
}

class InitRampSessionData {
  final String sessionToken;
  final String expiresAt;
  final String widgetUrl;

  const InitRampSessionData({
    required this.sessionToken,
    required this.expiresAt,
    required this.widgetUrl,
  });

  factory InitRampSessionData.fromJson(Map<String, dynamic> json) {
    return InitRampSessionData(
      sessionToken: json['session_token'] ?? '',
      expiresAt: json['expires_at'] ?? '',
      widgetUrl: json['widget_url'] ?? '',
    );
  }
}

class InitRampSessionResponse {
  final InitRampSessionData data;
  final String? error;
  final bool success;
  final String message;

  const InitRampSessionResponse({
    required this.data,
    this.error,
    required this.success,
    required this.message,
  });

  factory InitRampSessionResponse.fromJson(Map<String, dynamic> json) {
    return InitRampSessionResponse(
      data: InitRampSessionData.fromJson(json['data']),
      error: json['error'],
      success: json['success'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'session_token': data.sessionToken,
        'expires_at': data.expiresAt,
        'widget_url': data.widgetUrl,
      },
      'error': error,
      'success': success,
      'message': message,
    };
  }
}