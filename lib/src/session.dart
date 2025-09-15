import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/ramp_config.dart';

String _getBaseUrl(Environment environment) {
  if (environment == Environment.production) {
    return 'https://api.zbdpay.com';
  }
  return 'https://${environment.name}.zbdpay.com';
}

Future<T> _handleFailedResponse<T>(
    {required http.Response response, required String operation}) async {
  String errorMessage = '${response.statusCode} ${response.reasonPhrase}';
  try {
    final textBody = response.body;
    if (textBody.isNotEmpty) {
      try {
        final errorBody = jsonDecode(textBody);
        errorMessage += ' ${jsonEncode(errorBody)}';
      } catch (_) {
        errorMessage += ' $textBody';
      }
    }
  } catch (_) {
    // If reading response body fails, keep the basic error message
  }
  throw Exception('Failed to $operation: $errorMessage');
}

Future<InitRampSessionResponse> initRampSession(
    InitRampSessionConfig config) async {
  try {
    final baseUrl = _getBaseUrl(config.environment);
    final url = Uri.parse('$baseUrl/api/v1/ramp-widget');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': config.apikey,
      },
      body: jsonEncode(config.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      await _handleFailedResponse<InitRampSessionResponse>(
        response: response,
        operation: 'initRampSession',
      );
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return InitRampSessionResponse.fromJson(responseBody);
  } catch (error) {
    if (error is Exception) rethrow;
    throw Exception('Failed to initialize ramp session: $error');
  }
}

Future<RefreshAccessTokenResponse> refreshAccessToken(
    RefreshAccessTokenConfig config) async {
  try {
    final baseUrl = _getBaseUrl(config.environment);
    final url = Uri.parse('$baseUrl/api/v1/access-tokens/refresh');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': config.apikey,
      },
      body: jsonEncode(config.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      await _handleFailedResponse<RefreshAccessTokenResponse>(
        response: response,
        operation: 'refreshAccessToken',
      );
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return RefreshAccessTokenResponse.fromJson(responseBody);
  } catch (error) {
    if (error is Exception) rethrow;
    throw Exception('Failed to refresh access token: $error');
  }
}
