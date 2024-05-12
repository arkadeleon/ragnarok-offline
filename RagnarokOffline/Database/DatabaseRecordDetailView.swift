//
//  DatabaseRecordDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import SwiftUI
import rAthenaCommon

struct DatabaseRecordDetailView: View {
    let mode: ServerMode
    let record: any DatabaseRecord

    @State private var loadStatus: LoadStatus = .notYetLoaded
    @State private var detail = DatabaseRecordDetail(sections: [])

    var body: some View {
        ResponsiveView {
            List {
                ForEach(detail.sections) { section in
                    switch section {
                    case .image:
                        Section("") {

                        }
                    case .attributes(let title, let attributes):
                        Section(title) {
                            ForEach(attributes) { attribute in
                                LabeledContent(attribute.name, value: attribute.value)
                            }
                        }
                    case .description(let title, let description):
                        Section(title) {
                            Text(description)
                        }
                    case .script(let title, let script):
                        Section(title) {
                            Text(script)
                                .monospaced()
                        }
                    case .references(let title, let references):
                        Section(title) {
                            ForEach(references, id: \.recordID) { reference in
                                NavigationLink(reference.localizedName, value: reference)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
        } regular: {
            ScrollView {
            }
        }
        .task {
            await fetchDetail()
        }
    }

    private func fetchDetail() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        do {
            detail = try await record.detail(for: mode)

            loadStatus = .loaded
        } catch {
            loadStatus = .failed
        }
    }
}

//#Preview {
//    DatabaseRecordView()
//}
