import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/ramp_config.dart';

const Map<Environment, String> _environmentUrls = {
  Environment.production: 'https://api.zebedee.io',
  Environment.x1: 'https://x1.zebedee.io',
  Environment.x2: 'https://x2.zebedee.io',
  Environment.voltorb: 'https://voltorb.zebedee.io',
};

Future<InitRampSessionResponse> initRampSession(InitRampSessionConfig config) async {
  final baseUrl = _environmentUrls[config.environment] ?? _environmentUrls[Environment.production]!;
  final url = Uri.parse('$baseUrl/api/v1/ramp-widget');
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': config.apikey,
      },
      body: jsonEncode(config.toJson()),
    );

    print('Raw response body: ${response.body}');
    print('Response status code: ${response.statusCode}');
    
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    print('Parsed response data: $responseData');
    
    if ((response.statusCode == 200 || response.statusCode == 201) && responseData['success'] == true) {
      return InitRampSessionResponse.fromJson(responseData);
    } else {
      return InitRampSessionResponse(
        data: InitRampSessionData(
          sessionToken: '',
          expiresAt: '',
          widgetUrl: '',
        ),
        error: responseData['error'] ?? 'Failed to create session',
        success: false,
        message: responseData['message'] ?? 'Unknown error',
      );
    }
  } catch (error) {
    return InitRampSessionResponse(
      data: InitRampSessionData(
        sessionToken: '',
        expiresAt: '',
        widgetUrl: '',
      ),
      error: error.toString(),
      success: false,
      message: 'Network error: $error',
    );
  }
}