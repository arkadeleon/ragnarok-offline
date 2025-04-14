#!/bin/bash

cd Packages/swift-ro-tools
swift run code-generator generate-constants ../../swift-rathena ../swift-ro/Sources/ROConstants/Generated
swift run code-generator generate-packets ../../swift-rathena ../swift-ro/Sources/ROPackets/Generated
