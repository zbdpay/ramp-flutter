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
  final String? email;
  final String? accessToken;
  final String destination;
  final QuoteCurrency quoteCurrency;
  final BaseCurrency baseCurrency;
  final String? webhookUrl;
  final String? referenceId;
  final Map<String, dynamic>? metadata;
  final Environment environment;

  const InitRampSessionConfig({
    required this.apikey,
    this.email,
    this.accessToken,
    required this.destination,
    this.quoteCurrency = QuoteCurrency.USD,
    this.baseCurrency = BaseCurrency.BTC,
    this.webhookUrl,
    this.referenceId,
    this.metadata,
    this.environment = Environment.production,
  }) : assert(email != null || accessToken != null,
            'Either email or accessToken must be provided');

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'destination': destination,
      'quote_currency': quoteCurrency.name,
      'base_currency': baseCurrency.name,
    };

    if (email != null) {
      json['email'] = email;
    } else if (accessToken != null) {
      json['access_token'] = accessToken;
    }

    if (webhookUrl != null) {
      json['webhook_url'] = webhookUrl;
    }

    if (referenceId != null) {
      json['reference_id'] = referenceId;
    }

    if (metadata != null) {
      json['metadata'] = metadata;
    }

    return json;
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

class RefreshAccessTokenConfig {
  final String apikey;
  final String accessTokenId;
  final String refreshToken;
  final Environment environment;

  const RefreshAccessTokenConfig({
    required this.apikey,
    required this.accessTokenId,
    required this.refreshToken,
    this.environment = Environment.production,
  });

  Map<String, dynamic> toJson() {
    return {
      'access_token_id': accessTokenId,
      'refresh_token': refreshToken,
    };
  }
}

class RefreshAccessTokenData {
  final String accessTokenId;
  final String accessToken;
  final String refreshToken;
  final String accessTokenExpiresAt;
  final String refreshTokenExpiresAt;

  const RefreshAccessTokenData({
    required this.accessTokenId,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
  });

  factory RefreshAccessTokenData.fromJson(Map<String, dynamic> json) {
    return RefreshAccessTokenData(
      accessTokenId: json['access_token_id'] ?? '',
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      accessTokenExpiresAt: json['access_token_expires_at'] ?? '',
      refreshTokenExpiresAt: json['refresh_token_expires_at'] ?? '',
    );
  }
}

class RefreshAccessTokenResponse {
  final RefreshAccessTokenData data;
  final String? error;
  final bool success;
  final String message;

  const RefreshAccessTokenResponse({
    required this.data,
    this.error,
    required this.success,
    required this.message,
  });

  factory RefreshAccessTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshAccessTokenResponse(
      data: RefreshAccessTokenData.fromJson(json['data']),
      error: json['error'],
      success: json['success'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'access_token_id': data.accessTokenId,
        'access_token': data.accessToken,
        'refresh_token': data.refreshToken,
        'access_token_expires_at': data.accessTokenExpiresAt,
        'refresh_token_expires_at': data.refreshTokenExpiresAt,
      },
      'error': error,
      'success': success,
      'message': message,
    };
  }
}
