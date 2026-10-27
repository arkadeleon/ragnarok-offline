//
//  StorageView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/27.
//

import SwiftUI

struct StorageView: View {
    @State private var localClientSize: Int64?
    @State private var remoteClientCacheSize: Int64?
    @State private var serverSize: Int64?

    var body: some View {
        Form {
            Section {
                LabeledContent {
                    sizeLabel(localClientSize)
                } label: {
                    Text("Local Client", tableName: "Settings")
                }

                LabeledContent {
                    sizeLabel(remoteClientCacheSize)
                } label: {
                    Text("Remote Client Cache", tableName: "Settings")
                }

                LabeledContent {
                    sizeLabel(serverSize)
                } label: {
                    Text("Server", tableName: "Settings")
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(Text("Storage", tableName: "Settings"))
        .toolbarTitleDisplayMode(.inline)
        .task {
            async let localClientSize = directorySize(at: localClientURL)
            async let remoteClientCacheSize = directorySize(at: remoteClientCacheURL)
            async let serverSize = directorySize(at: serverWorkingDirectoryURL)

            self.localClientSize = await localClientSize
            self.remoteClientCacheSize = await remoteClientCacheSize
            self.serverSize = await serverSize
        }
    }

    @ViewBuilder
    private func sizeLabel(_ size: Int64?) -> some View {
        if let size {
            Text(size, format: .byteCount(style: .file))
        } else {
            ProgressView()
                .controlSize(.small)
        }
    }

    @concurrent
    private func directorySize(at url: URL) async -> Int64 {
        let keys: [URLResourceKey] = [.isRegularFileKey, .totalFileAllocatedSizeKey]
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys) else {
            return 0
        }

        var size: Int64 = 0
        while let fileURL = enumerator.nextObject() as? URL {
            let values = try? fileURL.resourceValues(forKeys: Set(keys))
            if values?.isRegularFile == true {
                size += Int64(values?.totalFileAllocatedSize ?? 0)
            }
        }
        return size
    }
}

#Preview {
    NavigationStack {
        StorageView()
    }
}
