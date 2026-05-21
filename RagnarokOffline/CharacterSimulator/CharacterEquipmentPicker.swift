//
//  CharacterEquipmentPicker.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/8/26.
//

import RagnarokResources
import SwiftUI

struct CharacterEquipmentPicker: View {
    var category: CharacterEquipmentCategory
    @Binding var selection: ItemModel?

    @Namespace private var equipmentNamespace

    @State private var isPicking = false

    var body: some View {
        LabeledContent {
            Button {
                isPicking = true
            } label: {
                if let selection {
                    Text(selection.displayName)
                } else {
                    Text("None", tableName: "CharacterSimulator")
                }
            }
            .buttonStyle(.bordered)
            .matchedTransitionSource(id: "equipment", in: equipmentNamespace)
        } label: {
            Text(category.nameResource)
        }
        .sheet(isPresented: $isPicking) {
            NavigationStack {
                CharacterEquipmentListView(category: category, selection: $selection)
            }
            .presentationSizing(.form)
            .adaptiveNavigationTransition(sourceID: "equipment", in: equipmentNamespace)
        }
    }
}

#Preview {
    @Previewable @State var selection: ItemModel? = nil

    List {
        CharacterEquipmentPicker(category: .headTop, selection: $selection)
    }
    .environment(DatabaseModel(mode: .renewal, resourceManager: .previewing))
}
