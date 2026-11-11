# Installing Ragnarok Offline on Apple Vision Pro

Ragnarok Offline puts a Ragnarok Online client and server in one app for Mac, iPhone, iPad and Apple Vision Pro. On Vision Pro, its beta game client renders the game's maps in a full immersive space.

## What you need

- A Mac on macOS 15.0 or later, with [Xcode](https://developer.apple.com/xcode/downloads/) and the iOS 18, macOS 15 and visionOS 2 SDKs
- Apple Vision Pro, connected to Xcode
- Your own Ragnarok Online client files: `data.grf` and the `BGM` folder from a kRO client folder

## Your game files

This repository contains no Ragnarok Online client data. The app reads `data.grf` and the `BGM` folder from its own folder in the Files app.

1. Install the app (below) and open it once.
2. In the Files app, copy `data.grf` and the `BGM` folder into *On My Apple Vision Pro > Ragnarok Offline*.

The app's Help screen describes ways to copy them across, from a Windows share over Wi-Fi or from a computer over USB; it's written for iPhone and iPad.

## Build from source

1. Make sure the Xcode command line tools point at the installed Xcode:

   ```shell
   xcode-select --install
   sudo xcode-select --switch /Applications/Xcode.app
   ```

2. From a checkout of this repository, fetch its submodules if you don't have them yet:

   ```shell
   git submodule update --init --recursive
   ```

3. Open `RagnarokOffline.xcodeproj` in Xcode and select the `RagnarokOffline` scheme.
4. The project is set up with its developer's signing team. Under *Signing & Capabilities*, choose your own team for the `RagnarokOffline` target and the `RagnarokOfflineThumbnailExtension` target; if Xcode reports that a bundle identifier isn't available to your team, change it to one of your own.
5. Choose your connected Apple Vision Pro as the run destination. An Apple Vision Pro Simulator works too.
6. Wait for Xcode to resolve the local Swift package dependencies, then build and run with *Product > Run*.
