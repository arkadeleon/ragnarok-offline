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
