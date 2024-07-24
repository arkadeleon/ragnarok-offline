//
//  LoginServerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/7/24.
//

import rAthenaLogin
import SwiftUI

struct LoginServerView: View {
    var loginServer: ObservableServer

    var body: some View {
        ServerView(server: loginServer)
    }
}

#Preview {
    let loginServer = ObservableServer(server: LoginServer.shared)
    return LoginServerView(loginServer: loginServer)
}
