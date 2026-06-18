//
//  ServerFilesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/18.
//

import SwiftUI

struct ServerFilesView: View {
    var directory: File

    var body: some View {
        FilesView("Server Files", directory: directory)
    }
}
