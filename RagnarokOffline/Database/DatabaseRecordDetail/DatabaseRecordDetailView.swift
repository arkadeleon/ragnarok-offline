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
    @State private var recordDetail = DatabaseRecordDetail(sections: [])

    var body: some View {
        ScrollView {
            ForEach(recordDetail.sections) { section in
                switch section {
                case .image:
                    DatabaseRecordInfoSection("") {

                    }
                case .attributes(let title, let attributes):
                    DatabaseRecordInfoSection(title) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 10) {
                            ForEach(attributes) { attribute in
                                LabeledContent(attribute.name, value: attribute.value)
                            }
                        }
                    }
                case .description(let title, let description):
                    DatabaseRecordInfoSection(title) {
                        Text(description)
                    }
                case .script(let title, let script):
                    DatabaseRecordInfoSection(title) {
                        Text(script)
                            .monospaced()
                    }
                case .references(let title, let references):
                    DatabaseRecordInfoSection(title) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(references, id: \.id) { reference in
                                NavigationLink(reference.recordName, value: reference)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }
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
            recordDetail = try await record.recordDetail(for: mode)

            loadStatus = .loaded
        } catch {
            loadStatus = .failed
        }
    }
}

//#Preview {
//    DatabaseRecordView()
//}
