#!/bin/bash

cd Packages/swift-ro-tools
swift run code-generator generate-constants ../../swift-rathena ../Constants/Sources/Constants/Generated
swift run code-generator generate-packets ../../swift-rathena ../swift-ro/Sources/ROPackets/Generated
