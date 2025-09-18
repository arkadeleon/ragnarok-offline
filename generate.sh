#!/bin/bash

cd RagnarokOfflineGenerator
swift run ragnarok-offline-generator generate-constants ../swift-rathena ../Packages/Constants/Sources/Constants/Generated
swift run ragnarok-offline-generator generate-packets ../swift-rathena ../Packages/NetworkClient/Sources/NetworkPackets/Generated
