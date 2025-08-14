//
//  AsyncContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import SwiftUI

enum AsyncContentStatus<Value> {
    case notYetLoaded
    case loading
    case loaded(Value)
    case failed(any Error)
}

struct AsyncContentView<Value, Content>: View where Content: View {
    var load: () async throws -> Value
    @ViewBuilder var content: (Value) -> Content

    @State private var status: AsyncContentStatus<Value> = .notYetLoaded

    var body: some View {
        ZStack {
            switch status {
            case .notYetLoaded:
                EmptyView()
            case .loading:
                ProgressView()
            case .loaded(let value):
                content(value)
            case .failed(let error):
                Text(error.localizedDescription)
                    .frame(width: 200)
                    .multilineTextAlignment(.center)
            }
        }
        .task {
            status = .loading

            do {
                let value = try await load()
                status = .loaded(value)
            } catch {
                status = .failed(error)
            }
        }
    }
}

#Preview {
    AsyncContentView {
        try await Task.sleep(for: .seconds(1))
    } content: {
        Image(systemName: "square.and.arrow.down.badge.checkmark")
    }
}
