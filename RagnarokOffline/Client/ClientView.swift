//
//  ClientView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct ClientView: View {

    var document: DocumentWrapper {
        let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return .url(url)
    }

    var body: some View {
        DocumentBrowserView(title: "Client", document: document)
    }
}
