#!/bin/bash

cd RagnarokOfflineGenerator
swift run ragnarok-offline-generator generate-constants ../swift-rathena ../Packages/RagnarokConstants/Sources/RagnarokConstants/Generated
swift run ragnarok-offline-generator generate-packets ../swift-rathena ../Packages/RagnarokNetwork/Sources/RagnarokPackets/Generated
