//
//  ClientView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct ClientView: View {

    let documentItem: DocumentItem

    var body: some View {
        DocumentItemsView(title: "Client", documentItem: documentItem)
    }

    init() {
        let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        documentItem = .directory(url)
    }
}
