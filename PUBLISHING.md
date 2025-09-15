# Publishing Guide

This guide covers how to manage versions, releases, and publishing for the ZBD Ramp Flutter package.

## Quick Start

### Development Commands (using Makefile)
```bash
make install       # Install dependencies
make format        # Run formatter
make test          # Run tests
make prerelease    # Run all pre-release checks
```

### Release Commands
```bash
make release-patch  # 1.0.0 → 1.0.1
make release-minor  # 1.0.0 → 1.1.0
make release-major  # 1.0.0 → 2.0.0
```

### Publishing
```bash
make publish-dry    # Test publishing without actually publishing
make publish        # Publish to pub.dev
```

## Workflow

### 1. Development
During development, add changes to the `## [Unreleased]` section in `CHANGELOG.md`:

```markdown
## [Unreleased]

### Added
- New feature X
- Support for Y

### Changed
- Updated Z behavior

### Fixed
- Fixed bug in A
```

### 2. Pre-release Checks
Before creating a release, run:
```bash
make prerelease
```

This will:
- Format your code
- Run static analysis
- Run all tests
- Perform a dry-run publish check

### 3. Creating a Release
Choose the appropriate release type:

```bash
make release-patch  # Bug fixes
make release-minor  # New features (backward compatible)
make release-major  # Breaking changes
```

The release script will:
1. Check that git working directory is clean
2. Run all pre-release checks
3. Update version in `pubspec.yaml`
4. Move unreleased changes to new version section in `CHANGELOG.md`
5. Create git commit and tag
6. Show next steps

### 4. Publishing to pub.dev

After creating a release:

1. **Review changes**:
   ```bash
   git show  # Review the commit
   ```

2. **Push to remote**:
   ```bash
   git push origin main --tags
   ```

3. **Publish to pub.dev**:
   ```bash
   make publish
   ```

## Tools Explained

### Makefile
Similar to `package.json` scripts in Node.js, provides convenient commands for development tasks.

### Release Script (`scripts/release.sh`)
Similar to `release-it` for Node.js:
- Automates version bumping
- Updates changelog
- Creates git commits and tags
- Runs pre-release checks

### Melos (`melos.yaml`)
Advanced package management for Dart (similar to npm workspaces):
- Provides additional scripting capabilities
- Useful for monorepos
- Install with: `dart pub global activate melos`

## Manual Commands

If you prefer not to use the Makefile:

### Installation
```bash
flutter pub get
```

### Development
```bash
dart format .                    # Format code
dart analyze --fatal-infos       # Static analysis
flutter test                     # Run tests
flutter test --coverage          # Run tests with coverage
```

### Publishing
```bash
flutter pub publish --dry-run    # Test publish
flutter pub publish              # Actual publish
```

### Release (manual)
```bash
./scripts/release.sh patch       # Patch release
./scripts/release.sh minor       # Minor release
./scripts/release.sh major       # Major release
```

## pub.dev Setup

Before first publish, you need:

1. **Pub.dev account**: Create at https://pub.dev
2. **Authentication**: Run `dart pub token add https://pub.dev`
3. **Package verification**: Ensure package name is available

## CI/CD Integration

For automated publishing in CI/CD:

### GitHub Actions Example
```yaml
name: Publish
on:
  push:
    tags: ['v*']
jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: make prerelease
      - run: flutter pub publish --force
        env:
          PUB_TOKEN: ${{ secrets.PUB_TOKEN }}
```

## Troubleshooting

### Common Issues

1. **"Package already exists"**
   - Check if version was already published
   - Increment version and try again

2. **"Analysis errors"**
   - Run `make format-fix` to auto-fix formatting
   - Fix remaining analysis issues manually

3. **"Working directory not clean"**
   - Commit or stash changes before releasing

4. **"Tests failed"**
   - Fix failing tests before releasing

### Getting Help
- Run `make help` for available commands
- Check `flutter pub publish --help` for publishing options
- Visit https://dart.dev/tools/pub/publishing for official docs