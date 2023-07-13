//
//  ContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaWeb
import rAthenaControl

struct ContentView: View {
    private let servers: [RAServer] = [
        RALoginServer.shared,
        RACharServer.shared,
        RAMapServer.shared,
        RAWebServer.shared,
    ]

    private let databases: [RADatabase] = [
        RAItemDatabase.shared,
        RAMonsterDatabase.shared,
        RAJobDatabase.shared,
        RASkillDatabase.shared,
        RASkillTreeDatabase.shared,
    ]

    var body: some View {
        NavigationView {
            List {
                Section("Client") {
                    NavigationLink {
                        ClientView()
                    } label: {
                        Label("Client", systemImage: "ipad.and.iphone")
                    }
                    NavigationLink {
                        GameView()
                    } label: {
                        Label("Game", systemImage: "xbox.logo")
                    }
                }

                Section("Servers") {
                    ForEach(servers, id: \.name) { server in
                        NavigationLink {
                            ServerView(server: server)
                        } label: {
                            Label(server.name, systemImage: "macpro.gen3.server")
                        }
                    }
                }

                Section("Databases") {
                    ForEach(databases, id: \.name) { database in
                        NavigationLink {
                            DatabaseView(database: database)
                        } label: {
                            Label(database.name, systemImage: "list.bullet.rectangle")
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Ragnarok Offline")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
