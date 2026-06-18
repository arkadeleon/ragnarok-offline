//
//  LocalClientFilesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/18.
//

import SwiftUI

struct LocalClientFilesView: View {
    var directory: File

    var body: some View {
        FilesView("Local Client Files", directory: directory)
    }
}
