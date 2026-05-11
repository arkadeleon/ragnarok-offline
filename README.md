# Ragnarok Offline

![](Screenshots/Simulator%20Screenshot%20-%20Apple%20Vision%20Pro.png)

## Prerequisites
Before installing Ragnarok Offline there are certain hardwares you will need.

Hardware | OS Version    | Required
---------|---------------|---------
Mac      | 15.0 or later | Yes
iPad     | 18.0 or later | No

## Installation

1. Install [Xcode](https://developer.apple.com/xcode/downloads/) with the iOS 18, macOS 15, and visionOS 2 SDKs.
1. Make sure the Xcode command line tools point at the installed Xcode:
    ```shell
    xcode-select --install
    sudo xcode-select --switch /Applications/Xcode.app
    ```
1. Clone the repository with submodules:
    ```shell
    git clone --recurse-submodules https://github.com/arkadeleon/ragnarok-offline
    cd ragnarok-offline
    ```
    If you already cloned the repository without submodules, run:
    ```shell
    git submodule update --init --recursive
    ```
1. Open `RagnarokOffline.xcodeproj` in Xcode.
1. Select the `RagnarokOffline` scheme.
1. Select a run destination:
    - `My Mac` to run the macOS app.
    - An iOS simulator to run on iPad or iPhone Simulator.
    - An Apple Vision Pro simulator to run the visionOS app.
    - A connected iPad, iPhone, or Apple Vision Pro device to run on real hardware.
1. Wait for Xcode to resolve local Swift package dependencies, then build and run with `Product > Run`.

### Code Signing and Certificates

The project is set up for automatic signing, but the checked-in settings contain the original author's Team ID and bundle identifiers. If Xcode reports a signing or provisioning error, open the `RagnarokOffline` target, go to `Signing & Capabilities`, and choose your own team. For real devices or distribution, also change the bundle identifier from `com.github.arkadeleon.ragnarok-offline` to an identifier that belongs to your Apple Developer account.

Run destination | Certificate or provisioning requirement
----------------|-----------------------------------------
macOS app on `My Mac` | No paid Apple Developer certificate is required for local debugging. Xcode can sign the debug build locally. If signing fails, choose your local team or use a local debug signing identity.
iOS Simulator | No certificate or provisioning profile is required.
visionOS Simulator | No certificate or provisioning profile is required.
Connected iPhone or iPad | Requires Xcode signing with an Apple ID or Apple Developer Program team. A real device must trust the developer profile and the bundle identifier must be unique to your team.
Connected Apple Vision Pro | Requires Xcode signing with an Apple Developer Program team and a valid provisioning profile for the device.
macOS distribution outside Xcode | Requires a Developer ID certificate and notarization if you want other Macs to run the app without Gatekeeper warnings.

The main app currently includes iCloud entitlements for the container `iCloud.com.github.arkadeleon.ragnarok-offline`. Simulator builds usually do not need you to create this container. Real-device builds and distributed builds need an iCloud container registered under your own Apple Developer team, or you need to remove the iCloud capability for local testing.
