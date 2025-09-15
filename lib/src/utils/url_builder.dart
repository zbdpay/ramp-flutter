import '../models/ramp_config.dart';

class UrlBuilder {
  static const Map<Environment, String> _environmentUrls = {
    Environment.production: 'https://ramp.zbdpay.com',
    Environment.x1: 'https://ramp.x1.zbdpay.com',
    Environment.x2: 'https://ramp.x2.zbdpay.com',
    Environment.voltorb: 'https://ramp.voltorb.zbdpay.com',
  };

  static String getWidgetUrl(Environment environment) {
    return _environmentUrls[environment] ??
        _environmentUrls[Environment.production]!;
  }

  static String buildWidgetUrl({
    required String baseUrl,
    required String sessionToken,
    String? secret,
  }) {
    final uri = Uri.parse(baseUrl);
    final queryParams = <String, String>{};

    queryParams['session_token'] = Uri.encodeComponent(sessionToken);

    if (secret != null) {
      queryParams['secret'] = secret;
    }

    return uri
        .replace(
          queryParameters: queryParams,
        )
        .toString();
  }
}
