#!/bin/zsh
set -euo pipefail

# ── Configuration ──────────────────────────────────────────────────────────────
APP_ID="6473837561"
TEAM_ID="GG76KD534U"
GROUP_ID="fe3f44a5-f63a-4fc0-b491-57bfae4494e5"
SCHEME="RagnarokOffline"
PROJECT="RagnarokOffline.xcodeproj"
XCCONFIG="Configurations/TestFlight.xcconfig"
BUILD_DIR="build/testflight"
export ASC_UPLOAD_TIMEOUT="${ASC_UPLOAD_TIMEOUT:-600s}"
# ───────────────────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()   { echo "${GREEN}▶${NC} $*"; }
warn()  { echo "${YELLOW}⚠${NC} $*"; }
error() { echo "${RED}✖${NC} $*" >&2; exit 1; }

usage() {
    echo "Usage: $(basename "$0") [ios|macos|all] [\"What's New\"]"
    echo "  ios   — Archive and upload iOS TestFlight build"
    echo "  macos — Archive and upload macOS TestFlight build"
    echo "  all   — Both platforms (default)"
    exit 1
}

PLATFORM="${1:-all}"
WHATS_NEW="${2:-}"
[[ "$PLATFORM" =~ ^(ios|macos|all)$ ]] || usage

# ── Preflight checks ───────────────────────────────────────────────────────────
command -v asc >/dev/null 2>&1 || error "asc not found — see github.com/rorkai/App-Store-Connect-CLI"
[[ -f "$PROJECT/project.pbxproj" ]] || error "Run this script from the repository root"

if xcpretty --version >/dev/null 2>&1; then
    PIPE="xcpretty"
else
    warn "xcpretty not available — raw xcodebuild output will be shown"
    PIPE="cat"
fi

# ── Read marketing version from xcconfig ──────────────────────────────────────
MARKETING_VERSION=$(grep "^MARKETING_VERSION" "$XCCONFIG" | sed 's/.*= *//')
[[ -n "$MARKETING_VERSION" ]] || error "Could not read MARKETING_VERSION from $XCCONFIG"

# ── Fetch next build number ────────────────────────────────────────────────────
log "Fetching next build number from App Store Connect..."
BUILD_NUMBER=$(asc builds next-build-number --app "$APP_ID" | python3 -c "import sys,json; print(json.load(sys.stdin)['nextBuildNumber'])")
log "Version: $MARKETING_VERSION, Build: $BUILD_NUMBER"

mkdir -p "$BUILD_DIR"

# ── Distribute: wait → what's new → add to group ──────────────────────────────
distribute() {
    local label="$1"
    local asc_platform="$2"

    log "[$label] Waiting for build $BUILD_NUMBER to appear in App Store Connect..."
    local build_id=""
    until [[ -n "$build_id" ]]; do
        sleep 15
        build_id=$(asc builds info --app "$APP_ID" --build-number "$BUILD_NUMBER" --platform "$asc_platform" 2>/dev/null \
            | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id') or d.get('data',{}).get('id',''))" 2>/dev/null || true)
    done

    log "[$label] Waiting for processing to complete..."
    asc builds wait --build-id "$build_id"

    if [[ -n "$WHATS_NEW" ]]; then
        log "[$label] Setting What's New..."
        asc builds test-notes create --build-id "$build_id" --locale "en-US" --whats-new "$WHATS_NEW" \
            || asc builds test-notes update --build-id "$build_id" --locale "en-US" --whats-new "$WHATS_NEW"
    fi

    log "[$label] Declaring encryption compliance..."
    asc builds update --app "$APP_ID" --build-number "$BUILD_NUMBER" --platform "$asc_platform" --uses-non-exempt-encryption=false

    log "[$label] Adding to TestFlight group..."
    asc builds add-groups --app "$APP_ID" --build-number "$BUILD_NUMBER" --platform "$asc_platform" --group "$GROUP_ID" --submit --confirm
    log "[$label] Distributed to testers."
}

# ── iOS ────────────────────────────────────────────────────────────────────────
archive_ios() {
    local archive="$BUILD_DIR/RagnarokOffline-iOS.xcarchive"
    local export_dir="$BUILD_DIR/iOS"
    local options="$BUILD_DIR/ExportOptions-iOS.plist"

    rm -rf "$archive" "$export_dir"

    log "[iOS] Archiving..."
    xcodebuild archive \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration Release \
        -xcconfig "$XCCONFIG" \
        -destination "generic/platform=iOS" \
        -archivePath "$archive" \
        CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
        | $PIPE

    cat > "$options" <<-PLIST
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
	    <key>method</key>
	    <string>app-store-connect</string>
	    <key>teamID</key>
	    <string>$TEAM_ID</string>
	    <key>destination</key>
	    <string>export</string>
	    <key>signingStyle</key>
	    <string>manual</string>
	    <key>provisioningProfiles</key>
	    <dict>
	        <key>com.github.arkadeleon.ragnarok-offline</key>
	        <string>Ragnarok Offline</string>
	        <key>com.github.arkadeleon.ragnarok-offline.thumbnail-extension</key>
	        <string>Ragnarok Offline Thumbnail Extension</string>
	    </dict>
	</dict>
	</plist>
	PLIST

    log "[iOS] Exporting..."
    xcodebuild -exportArchive \
        -archivePath "$archive" \
        -exportPath "$export_dir" \
        -exportOptionsPlist "$options" \
        | $PIPE

    local ipa
    ipa=$(find "$export_dir" -name "*.ipa" | head -1)
    [[ -n "$ipa" ]] || error "[iOS] No .ipa found after export"

    log "[iOS] Uploading to TestFlight..."
    asc builds upload --app "$APP_ID" --ipa "$ipa" --version "$MARKETING_VERSION" --build-number "$BUILD_NUMBER"
}

# ── macOS ──────────────────────────────────────────────────────────────────────
archive_macos() {
    local archive="$BUILD_DIR/RagnarokOffline-macOS.xcarchive"
    local export_dir="$BUILD_DIR/macOS"
    local options="$BUILD_DIR/ExportOptions-macOS.plist"

    rm -rf "$archive" "$export_dir"

    log "[macOS] Archiving..."
    xcodebuild archive \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration Release \
        -xcconfig "$XCCONFIG" \
        -destination "generic/platform=macOS" \
        -archivePath "$archive" \
        CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
        | $PIPE

    cat > "$options" <<-PLIST
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
	    <key>method</key>
	    <string>app-store-connect</string>
	    <key>teamID</key>
	    <string>$TEAM_ID</string>
	    <key>destination</key>
	    <string>export</string>
	    <key>signingStyle</key>
	    <string>manual</string>
	    <key>signingCertificate</key>
	    <string>Apple Distribution</string>
	    <key>installerSigningCertificate</key>
	    <string>3rd Party Mac Developer Installer</string>
	    <key>provisioningProfiles</key>
	    <dict>
	        <key>com.github.arkadeleon.ragnarok-offline</key>
	        <string>Ragnarok Offline Mac</string>
	    </dict>
	</dict>
	</plist>
	PLIST

    log "[macOS] Exporting..."
    xcodebuild -exportArchive \
        -archivePath "$archive" \
        -exportPath "$export_dir" \
        -exportOptionsPlist "$options" \
        | $PIPE

    local pkg
    pkg=$(find "$export_dir" -name "*.pkg" | head -1)
    [[ -n "$pkg" ]] || error "[macOS] No .pkg found after export"

    log "[macOS] Uploading to TestFlight..."
    asc builds upload --app "$APP_ID" --pkg "$pkg" --version "$MARKETING_VERSION" --build-number "$BUILD_NUMBER"
}

# ── Dispatch ───────────────────────────────────────────────────────────────────
case "$PLATFORM" in
    ios)
        archive_ios
        distribute "iOS" "IOS"
        ;;
    macos)
        archive_macos
        distribute "macOS" "MAC_OS"
        ;;
    all)
        archive_ios
        archive_macos
        distribute "iOS" "IOS"
        distribute "macOS" "MAC_OS"
        ;;
esac

log "All done. Build $BUILD_NUMBER is live in TestFlight."
