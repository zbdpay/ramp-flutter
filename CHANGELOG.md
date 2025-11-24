# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]




## [1.0.2] - 2025-11-24
### Fixed
- PostMessage communication now works properly in WebView by listening to CustomEvent instead of relying on fake parent window
- Widget event messages (WIDGET_READY, WIDGET_STEP_CHANGE, etc.) now properly received in Flutter
- Fixed CORS issues in WebView by adding proper cache and cookie settings
- Improved debug logging to show actual message content instead of [object Object]
- Fixed WIDGET_TRANSACTION_COMPLETE event name to match SDK
- Fixed StepChange payload to pass full object with previousStep and currentStep
### Added
- CustomEvent bridge for WebView PostMessage communication


## [1.0.1] - 2025-11-24
### Changed
- Updated session logic to match TypeScript implementation
- Webview library updated
- Plaid and Onfido flows fixed
### Added
- Support for access_token authentication in addition to email
- RefreshAccessToken functionality
- Improved error handling with proper HTTP status code checking
### Fixed
- Base URL generation now uses zbdpay.com instead of zebedee.io


## [1.0.0] - 2024-08-08

### Added
- Initial release
- Flutter widget wrapper for ZBD Ramp
- `ZBDRampWidget` with controller support
- Cross-platform support (iOS, Android, Web)
- WebView integration with Flutter
- Comprehensive Dart type definitions
