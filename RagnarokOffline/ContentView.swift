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
                        let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                        DocumentBrowserView(title: "Browse", document: .url(url))
                    } label: {
                        Label("Browse", systemImage: "folder")
                    }

                    NavigationLink {
                        GameView()
                    } label: {
                        Label("Game", systemImage: "gamecontroller")
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
