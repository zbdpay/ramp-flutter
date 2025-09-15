# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Widget now expands to fill available space when no dimensions specified (instead of fixed 600px height)
- Updated session logic to match TypeScript implementation
- Removed test/debug code that loaded Google.com in WebView

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
- PostMessage communication handling