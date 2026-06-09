//
//  AsyncContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import SwiftUI

enum AsyncContentState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(any Error)
}

struct AsyncContentView<Value, Content, Placeholder>: View where Value: Sendable, Content: View, Placeholder: View {
    var load: () async throws -> Value
    var content: (Value) -> Content
    var placeholder: Placeholder

    @State private var state: AsyncContentState<Value> = .idle

    var body: some View {
        ZStack {
            switch state {
            case .idle:
                EmptyView()
            case .loading:
                placeholder
            case .loaded(let value):
                content(value)
            case .failed(let error):
                Text(error.localizedDescription)
                    .frame(width: 200)
                    .multilineTextAlignment(.center)
            }
        }
        .task {
            state = .loading

            do {
                let value = try await load()
                state = .loaded(value)
            } catch {
                state = .failed(error)
            }
        }
    }

    init(
        load: @escaping () async throws -> Value,
        @ViewBuilder content: @escaping (Value) -> Content
    ) where Placeholder == ProgressView<EmptyView, EmptyView> {
        self.load = load
        self.content = content
        self.placeholder = ProgressView()
    }

    init(
        load: @escaping () async throws -> Value,
        @ViewBuilder content: @escaping (Value) -> Content,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.load = load
        self.content = content
        self.placeholder = placeholder()
    }
}

#Preview {
    AsyncContentView {
        try await Task.sleep(for: .seconds(1))
    } content: {
        Image(systemName: "square.and.arrow.down.badge.checkmark")
    }
}
