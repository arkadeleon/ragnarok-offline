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
    case failed(Error)
}

struct AsyncContentView<Value, Content>: View where Content: View {
    let status: AsyncContentStatus<Value>
    let content: (Value) -> Content

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
            }
        }
    }

    init(status: AsyncContentStatus<Value>, @ViewBuilder content: @escaping (Value) -> Content) {
        self.status = status
        self.content = content
    }
}

#Preview {
    AsyncContentView(status: .loaded("")) { text in
        Text(text)
    }
}
