//
//  ItemDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/3/1.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaCommon

struct ItemDetailView: View {
    @EnvironmentObject var database: Database

    let item: RAItem

    var body: some View {
        List {
            ForEach(item.attributes, id: \.name) { attribute in
                HStack {
                    Text(attribute.name)
                    Spacer()
                    Text(attribute.value)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle(item.name)
    }
}
