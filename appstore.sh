#!/bin/zsh
set -euo pipefail

# ── Configuration ──────────────────────────────────────────────────────────────
APP_ID="6473837561"
TEAM_ID="GG76KD534U"
SCHEME="RagnarokOffline"
PROJECT="RagnarokOffline.xcodeproj"
XCCONFIG="Configurations/AppStore.xcconfig"
BUILD_DIR="build/appstore"
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
    echo "Usage: $(basename "$0") [ios|macos|visionos|all]"
    echo "  ios      — Archive and upload iOS App Store build"
    echo "  macos    — Archive and upload macOS App Store build"
    echo "  visionos — Archive and upload visionOS App Store build"
    echo "  all      — All platforms (default)"
    exit 1
}

PLATFORM="${1:-all}"
[[ "$PLATFORM" =~ ^(ios|macos|visionos|all)$ ]] || usage

# ── Preflight checks ───────────────────────────────────────────────────────────
command -v asc >/dev/null 2>&1 || error "asc not found — see github.com/rorkai/App-Store-Connect-CLI"
[[ -f "$PROJECT/project.pbxproj" ]] || error "Run this script from the repository root"
[[ -f "$XCCONFIG" ]] || error "xcconfig not found: $XCCONFIG"

if xcpretty --version >/dev/null 2>&1; then
    PIPE="xcpretty"
else
    warn "xcpretty not available — raw xcodebuild output will be shown"
    PIPE="cat"
fi

# ── Read versions from xcconfig ───────────────────────────────────────────────
MARKETING_VERSION=$(grep "^MARKETING_VERSION" "$XCCONFIG" | sed 's/.*= *//')
[[ -n "$MARKETING_VERSION" ]] || error "Could not read MARKETING_VERSION from $XCCONFIG"

BUILD_NUMBER=$(grep "^CURRENT_PROJECT_VERSION" "$XCCONFIG" | sed 's/.*= *//')
[[ -n "$BUILD_NUMBER" ]] || error "Could not read CURRENT_PROJECT_VERSION from $XCCONFIG"

log "Version: $MARKETING_VERSION, Build: $BUILD_NUMBER"

mkdir -p "$BUILD_DIR"

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

    log "[iOS] Uploading to App Store Connect..."
    asc builds upload \
        --app "$APP_ID" \
        --platform IOS \
        --ipa "$ipa" \
        --version "$MARKETING_VERSION" \
        --build-number "$BUILD_NUMBER" \
        --verify-timeout "$ASC_UPLOAD_TIMEOUT" \
        --wait
    log "[iOS] Upload complete."
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

    log "[macOS] Uploading to App Store Connect..."
    asc builds upload \
        --app "$APP_ID" \
        --platform MAC_OS \
        --pkg "$pkg" \
        --version "$MARKETING_VERSION" \
        --build-number "$BUILD_NUMBER" \
        --verify-timeout "$ASC_UPLOAD_TIMEOUT" \
        --wait
    log "[macOS] Upload complete."
}

# ── visionOS ──────────────────────────────────────────────────────────────────
archive_visionos() {
    local archive="$BUILD_DIR/RagnarokOffline-visionOS.xcarchive"
    local export_dir="$BUILD_DIR/visionOS"
    local options="$BUILD_DIR/ExportOptions-visionOS.plist"

    rm -rf "$archive" "$export_dir"

    log "[visionOS] Archiving..."
    xcodebuild archive \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration Release \
        -xcconfig "$XCCONFIG" \
        -destination "generic/platform=visionOS" \
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

    log "[visionOS] Exporting..."
    xcodebuild -exportArchive \
        -archivePath "$archive" \
        -exportPath "$export_dir" \
        -exportOptionsPlist "$options" \
        | $PIPE

    local ipa
    ipa=$(find "$export_dir" -name "*.ipa" | head -1)
    [[ -n "$ipa" ]] || error "[visionOS] No .ipa found after export"

    log "[visionOS] Uploading to App Store Connect..."
    asc builds upload \
        --app "$APP_ID" \
        --platform VISION_OS \
        --ipa "$ipa" \
        --version "$MARKETING_VERSION" \
        --build-number "$BUILD_NUMBER" \
        --verify-timeout "$ASC_UPLOAD_TIMEOUT" \
        --wait
    log "[visionOS] Upload complete."
}

# ── Dispatch ───────────────────────────────────────────────────────────────────
case "$PLATFORM" in
    ios)
        archive_ios
        ;;
    macos)
        archive_macos
        ;;
    visionos)
        archive_visionos
        ;;
    all)
        archive_ios
        archive_macos
        archive_visionos
        ;;
esac

log "All done. Build $BUILD_NUMBER uploaded — submit via App Store Connect."
