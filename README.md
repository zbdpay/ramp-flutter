# zbd_ramp

Flutter package for ZBD Ramp widget that enables Bitcoin purchase interface for Flutter applications.

## Features

- ✅ **Flutter Optimized**: Built specifically for Flutter with native WebView
- ✅ **Cross-Platform**: Works on iOS, Android, and Web
- ✅ **Type Safe**: Full Dart type safety with comprehensive type definitions
- ✅ **PostMessage Communication**: Real-time error handling, logging, and step tracking
- ✅ **Session Management**: Built-in session token creation and management

## Try the Example App

**Quick way to test the package:**

1. **Clone and navigate to the example:**
   ```bash
   git clone https://github.com/zbdpay/ramp-flutter.git
   cd ramp-flutter/example
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the example:**
   ```bash
   flutter run
   ```

4. **Test with your credentials:**
   - Enter your ZBD API Key
   - Fill in email and Lightning destination
   - Tap "Create Session & Load Ramp"

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  zbd_ramp: ^1.0.0
  http: ^1.1.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Create Session Token

First, create a session token using the ZBD API:

```dart
import 'package:zbd_ramp/zbd_ramp.dart';

// Using email authentication
final response = await initRampSession(InitRampSessionConfig(
  apikey: 'your-zbd-api-key',
  email: 'user@example.com',
  destination: 'lightning-address-or-username',
  quoteCurrency: QuoteCurrency.USD,
  baseCurrency: BaseCurrency.BTC,
  webhookUrl: 'https://your-webhook-url.com',
));

// Or using access token authentication
final response = await initRampSession(InitRampSessionConfig(
  apikey: 'your-zbd-api-key',
  accessToken: 'user-access-token',
  destination: 'lightning-address-or-username',
  quoteCurrency: QuoteCurrency.USD,
  baseCurrency: BaseCurrency.BTC,
  webhookUrl: 'https://your-webhook-url.com',
));

final sessionToken = response.data.sessionToken;
```

### 2. Create and Display Ramp Widget

```dart
import 'package:flutter/material.dart';
import 'package:zbd_ramp/zbd_ramp.dart';

class PaymentScreen extends StatelessWidget {
  final String sessionToken;

  const PaymentScreen({Key? key, required this.sessionToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ZBD Payment')),
      body: ZBDRampWidget(
        config: RampConfig(sessionToken: sessionToken),
        callbacks: RampCallbacks(
          onSuccess: (data) => print('Payment successful: $data'),
          onError: (error) => print('Payment error: ${error.message}'),
          onStepChange: (step) => print('Current step: $step'),
        ),
        height: 600,
      ),
    );
  }
}
```

## API Reference

### initRampSession(config)

Creates a new session token for the ZBD Ramp widget.

#### Parameters

```dart
class InitRampSessionConfig {
  final String apikey;                            // Required: Your ZBD API key
  final String? email;                            // Email authentication
  final String? accessToken;                     // Access token authentication
  final String destination;                       // Required: Lightning address or username
  final QuoteCurrency quoteCurrency;              // Required: Quote currency (USD)
  final BaseCurrency baseCurrency;                // Required: Base currency (BTC)
  final String? webhookUrl;                       // Optional: Webhook URL for notifications
  final String? referenceId;                      // Optional: Your reference ID
  final Map<String, dynamic>? metadata;           // Optional: Additional metadata
}

// Note: Either email OR accessToken must be provided
```

#### Returns

```dart
class InitRampSessionResponse {
  final InitRampSessionData data;                 // Session data
  final String? error;                            // Error message if failed
  final bool success;                             // Success status
  final String message;                           // Response message
}

class InitRampSessionData {
  final String sessionToken;                     // Session token for widget
  final String expiresAt;                        // Token expiration time
  final String widgetUrl;                        // Direct widget URL
}
```

#### Example

```dart
import 'package:zbd_ramp/zbd_ramp.dart';

// Using email authentication
try {
  final response = await initRampSession(InitRampSessionConfig(
    apikey: 'your-zbd-api-key',
    email: 'user@example.com',
    destination: 'lightning-address',
    quoteCurrency: QuoteCurrency.USD,
    baseCurrency: BaseCurrency.BTC,
    webhookUrl: 'https://your-webhook.com',
    referenceId: 'order-123',
    metadata: {'userId': '456', 'plan': 'premium'},
  ));

  if (response.success) {
    final sessionToken = response.data.sessionToken;
    // Use sessionToken with ZBDRampWidget
  } else {
    print('Failed to create session: ${response.error}');
  }
} catch (error) {
  print('Session creation error: $error');
}

// Using access token authentication
try {
  final response = await initRampSession(InitRampSessionConfig(
    apikey: 'your-zbd-api-key',
    accessToken: 'user-access-token',
    destination: 'lightning-address',
    quoteCurrency: QuoteCurrency.USD,
    baseCurrency: BaseCurrency.BTC,
    webhookUrl: 'https://your-webhook.com',
    referenceId: 'order-123',
    metadata: {'userId': '456', 'plan': 'premium'},
  ));

  if (response.success) {
    final sessionToken = response.data.sessionToken;
    // Use sessionToken with ZBDRampWidget
  } else {
    print('Failed to create session: ${response.error}');
  }
} catch (error) {
  print('Session creation error: $error');
}
```

### refreshAccessToken(config)

Refreshes an expired access token using a refresh token.

**Token Lifecycle:**
- Access tokens expire after **30 days**
- Refresh tokens expire after **90 days**
- Both tokens are received via webhook after user completes OTP login with email

#### Parameters

```dart
class RefreshAccessTokenConfig {
  final String apikey;                            // Required: Your ZBD API key
  final String accessTokenId;                     // Required: ID of the access token to refresh
  final String refreshToken;                      // Required: Refresh token
}
```

#### Returns

```dart
class RefreshAccessTokenResponse {
  final RefreshAccessTokenData data;              // Token data
  final String? error;                            // Error message if failed
  final bool success;                             // Success status
  final String message;                           // Response message
}

class RefreshAccessTokenData {
  final String accessTokenId;                     // Access token ID
  final String accessToken;                       // New access token
  final String refreshToken;                      // New refresh token
  final String accessTokenExpiresAt;              // Access token expiration time
  final String refreshTokenExpiresAt;             // Refresh token expiration time
}
```

#### Example

```dart
import 'package:zbd_ramp/zbd_ramp.dart';

try {
  final response = await refreshAccessToken(RefreshAccessTokenConfig(
    apikey: 'your-zbd-api-key',
    accessTokenId: '7b585ffa-9473-43ca-ba1d-56e9e7e2263b',
    refreshToken: 'user-refresh-token',
  ));

  if (response.success) {
    final newAccessToken = response.data.accessToken;
    final newRefreshToken = response.data.refreshToken;
    // Store the new tokens securely
  } else {
    print('Failed to refresh token: ${response.error}');
  }
} catch (error) {
  print('Token refresh error: $error');
}
```

### ZBDRampWidget

Main Flutter widget that renders the ZBD Ramp interface.

#### Constructor

```dart
ZBDRampWidget({
  Key? key,
  required RampConfig config,
  required RampCallbacks callbacks,
  double? width,
  double? height,
})
```

### RampConfig

Configuration for the ZBD Ramp widget.

```dart
class RampConfig {
  final String sessionToken;                     // Required: Your session token
  final String? secret;                          // Optional: Widget secret
}
```

### RampCallbacks

Callback functions for handling widget events.

```dart
class RampCallbacks {
  final OnSuccessCallback? onSuccess;            // Payment successful
  final OnErrorCallback? onError;                // Error occurred  
  final OnStepChangeCallback? onStepChange;      // User navigated to different step
  final OnLogCallback? onLog;                    // Debug/info logging
  final OnReadyCallback? onReady;                // Widget fully loaded
  final OnCloseCallback? onClose;                // User closed widget
}
```

## Examples

### Basic Usage

```dart
ZBDRampWidget(
  config: RampConfig(sessionToken: 'your-session-token'),
  callbacks: RampCallbacks(
    onSuccess: (data) => print('Payment successful: $data'),
    onError: (error) => print('Error: ${error.message}'),
  ),
  height: 600,
)
```

### With Callbacks

```dart
ZBDRampWidget(
  config: RampConfig(sessionToken: 'your-session-token'),
  callbacks: RampCallbacks(
    onSuccess: (data) {
      print('Payment successful: $data');
      // Handle successful payment
    },
    onError: (error) {
      print('Payment error: ${error.message}');
      // Handle error
    },
    onStepChange: (step) {
      print('Current step: $step');
      // Track user progress
    },
    onReady: () {
      print('Widget ready');
      // Widget fully loaded
    },
  ),
  height: 600,
)
```

### Error Handling

```dart
void _handleError(RampError error) {
  // Error structure: { code: string, message: string, details?: any }
  print('Error: ${error.code} - ${error.message}');
  if (error.details != null) {
    print('Details: ${error.details}');
  }
}
```

## Platform Setup

### iOS

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
<key>NSCameraUsageDescription</key>
<string>Camera access is required for KYC flow</string>
```

### Android

Add the following to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.VIDEO_CAPTURE" />
<uses-permission android:name="android.permission.AUDIO_CAPTURE" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## Framework Integrations

This is the Flutter package. For other framework integrations, see:

- **Core**: [`@zbdpay/ramp-ts`](https://www.npmjs.com/package/@zbdpay/ramp-ts) - Core TypeScript/JavaScript package
- **React**: [`@zbdpay/ramp-react`](https://www.npmjs.com/package/@zbdpay/ramp-react)
- **React Native**: [`@zbdpay/ramp-react-native`](https://www.npmjs.com/package/@zbdpay/ramp-react-native)

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support create an issue on GitHub.