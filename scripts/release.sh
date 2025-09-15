#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PUBSPEC_FILE="$PROJECT_ROOT/pubspec.yaml"
CHANGELOG_FILE="$PROJECT_ROOT/CHANGELOG.md"

log_info() {
    echo "[INFO] $1"
}

log_success() {
    echo "[SUCCESS] $1"
}

log_warning() {
    echo "[WARNING] $1"
}

log_error() {
    echo "[ERROR] $1"
}

check_git_repo() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_error "Not in a git repository"
        exit 1
    fi
}

check_git_clean() {
    if [[ -n $(git status --porcelain) ]]; then
        log_error "Working directory is not clean. Please commit or stash changes."
        git status --short
        exit 1
    fi
}

get_current_version() {
    grep '^version:' "$PUBSPEC_FILE" | sed 's/version: //' | tr -d ' '
}

increment_version() {
    local current_version=$1
    local increment_type=$2

    local clean_version=$(echo "$current_version" | cut -d'+' -f1)

    local IFS='.'
    local version_parts=($clean_version)
    local major=${version_parts[0]}
    local minor=${version_parts[1]}
    local patch=${version_parts[2]}

    case $increment_type in
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            ;;
        "patch")
            patch=$((patch + 1))
            ;;
        *)
            log_error "Invalid increment type: $increment_type"
            exit 1
            ;;
    esac

    echo "$major.$minor.$patch"
}

update_pubspec_version() {
    local new_version=$1
    log_info "Updating pubspec.yaml to version $new_version"
    sed -i "s/^version: .*/version: $new_version/" "$PUBSPEC_FILE"
}

update_changelog() {
    local new_version=$1
    local current_date=$(date +%Y-%m-%d)

    log_info "Updating CHANGELOG.md for version $new_version"

    local temp_changelog=$(mktemp)
    local in_unreleased=false
    local unreleased_content=""

    while IFS= read -r line; do
        if [[ "$line" == "## [Unreleased]" ]]; then
            in_unreleased=true
            echo "$line" >> "$temp_changelog"
            continue
        elif [[ "$line" =~ ^##\ \[.*\] ]] && [[ "$in_unreleased" == true ]]; then
            echo "" >> "$temp_changelog"
            echo "## [$new_version] - $current_date" >> "$temp_changelog"
            if [[ -n "$unreleased_content" ]]; then
                echo "$unreleased_content" >> "$temp_changelog"
            else
                echo "" >> "$temp_changelog"
                echo "### Changed" >> "$temp_changelog"
                echo "- Release version $new_version" >> "$temp_changelog"
            fi
            echo "" >> "$temp_changelog"
            echo "$line" >> "$temp_changelog"
            in_unreleased=false
            continue
        elif [[ "$in_unreleased" == true ]] && [[ "$line" != "" ]]; then
            unreleased_content+="$line"$'\n'
            continue
        fi

        echo "$line" >> "$temp_changelog"
    done < "$CHANGELOG_FILE"

    mv "$temp_changelog" "$CHANGELOG_FILE"
}

run_prerelease_checks() {
    log_info "Running pre-release checks..."

    log_info "Formatting code..."
    dart format . >/dev/null 2>&1 || true

    log_info "Running static analysis..."
    if ! dart analyze --fatal-infos; then
        log_error "Static analysis failed"
        exit 1
    fi

    log_info "Running tests..."
    if ! flutter test; then
        log_error "Tests failed"
        exit 1
    fi

    log_info "Running publish dry-run..."
    if ! flutter pub publish --dry-run; then
        log_error "Publish dry-run failed"
        exit 1
    fi

    log_success "All pre-release checks passed!"
}

create_git_release() {
    local version=$1

    log_info "Creating git commit and tag for version $version"

    git add "$PUBSPEC_FILE" "$CHANGELOG_FILE"

    git commit -m "chore(release): $version

🤖 Generated with release script

Co-Authored-By: Claude <noreply@anthropic.com>"

    git tag "v$version" -m "Release v$version"

    log_success "Created commit and tag for v$version"
}

main() {
    local increment_type=${1:-"patch"}

    log_info "Starting $increment_type release process..."

    if [[ ! "$increment_type" =~ ^(major|minor|patch)$ ]]; then
        log_error "Usage: $0 [major|minor|patch]"
        exit 1
    fi

    check_git_repo
    check_git_clean

    local current_version
    current_version=$(get_current_version)
    log_info "Current version: $current_version"

    local new_version
    new_version=$(increment_version "$current_version" "$increment_type")
    log_info "New version will be: $new_version"

    echo ""
    log_warning "This will create a $increment_type release: $current_version → $new_version"
    read -p "Continue? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Release cancelled"
        exit 0
    fi

    run_prerelease_checks

    update_pubspec_version "$new_version"
    update_changelog "$new_version"

    create_git_release "$new_version"

    echo ""
    log_success "Release v$new_version created successfully!"
    echo ""
    log_info "Next steps:"
    echo "  1. Review the changes: git show"
    echo "  2. Push to remote: git push origin main --tags"
    echo "  3. Publish to pub.dev: flutter pub publish"
    echo ""
    log_warning "To publish immediately, run: flutter pub publish"
}

main "$@"