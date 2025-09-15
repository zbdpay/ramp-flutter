.PHONY: help install clean analyze format test build publish release

help:
	@echo "Available commands:"
	@echo "  install       Install dependencies"
	@echo "  clean         Clean generated files"
	@echo "  analyze       Run static analysis"
	@echo "  format        Format Dart code"
	@echo "  format-fix    Format and fix Dart code"
	@echo "  test          Run tests"
	@echo "  test-coverage Run tests with coverage"
	@echo "  build-example Build example app"
	@echo "  publish-dry   Dry run publish to pub.dev"
	@echo "  publish       Publish to pub.dev"
	@echo "  prerelease    Run pre-release checks"
	@echo "  release-patch Create patch release"
	@echo "  release-minor Create minor release"
	@echo "  release-major Create major release"

install:
	flutter pub get

clean:
	flutter clean

analyze:
	dart analyze --fatal-infos

format:
	dart format --set-exit-if-changed .

format-fix:
	dart format .

test:
	flutter test

test-coverage:
	flutter test --coverage

build-example:
	cd example && flutter build apk --debug
	cd example && flutter build web

publish-dry:
	flutter pub publish --dry-run

publish:
	flutter pub publish

prerelease: format analyze test publish-dry

release-patch:
	./scripts/release.sh patch

release-minor:
	./scripts/release.sh minor

release-major:
	./scripts/release.sh major