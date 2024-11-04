//
//  DatabaseRecordDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import RODatabase
import SwiftUI

struct DatabaseRecordDetailView: View {
    var mode: DatabaseMode
    var record: any DatabaseRecord

    @State private var loadStatus: LoadStatus = .notYetLoaded
    @State private var recordDetail = DatabaseRecordDetail(sections: [])

    var body: some View {
        ScrollView {
            ForEach(recordDetail.sections) { section in
                switch section {
                case .image(let title, let image):
                    DatabaseRecordInfoSection {
                        Image(image, scale: 1, label: Text(title))
                    } header: {
                        Text(title)
                    }
                case .attributes(let title, let attributes):
                    DatabaseRecordInfoSection {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 10) {
                            ForEach(attributes) { attribute in
                                LabeledContent {
                                    Text(attribute.value)
                                } label: {
                                    Text(attribute.name)
                                }
                            }
                        }
                    } header: {
                        Text(title)
                    }
                case .description(let title, let description):
                    DatabaseRecordInfoSection {
                        Text(description)
                    } header: {
                        Text(title)
                    }
                case .script(let title, let script):
                    DatabaseRecordInfoSection {
                        Text(script)
                            .monospaced()
                    } header: {
                        Text(title)
                    }
                case .references(let title, let references):
                    DatabaseRecordInfoSection {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(references, id: \.id) { reference in
                                NavigationLink(reference.recordName, value: reference)
                                    .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 20)
                    } header: {
                        Text(title)
                    }
                }
            }
        }
        .background(.background)
        .navigationTitle(record.recordName)
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
