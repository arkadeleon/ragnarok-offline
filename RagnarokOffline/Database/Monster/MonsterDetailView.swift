//
//  MonsterDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import RagnarokDatabase
import SwiftUI

struct MonsterDetailView: View {
    var monster: MonsterModel

    @Environment(DatabaseModel.self) private var database

    @State private var elementalDamages: [ElementalDamage] = []
    @State private var mvpDropItems: [DropItem] = []
    @State private var dropItems: [DropItem] = []
    @State private var castSkills: [MonsterCastSkill] = []
    @State private var spawnMaps: [SpawnMap] = []

    var body: some View {
        DatabaseRecordDetailView {
            ZStack {
                if let animatedImage = monster.animatedImage {
                    AnimatedImageView(animatedImage: animatedImage)
                } else {
                    Image(systemName: "pawprint")
                        .font(.system(size: 100, weight: .thin))
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(height: 200)
            .stretchy()

            DatabaseRecordSectionView(attributes: monster.attributes) {
                Text("Info", tableName: "Database")
            }

            DatabaseRecordSectionView(attributes: monster.statAttributes) {
                Text("Stats", tableName: "Database")
            }

            DatabaseRecordSectionView(attributes: monster.actionAttributes) {
                Text("Actions", tableName: "Database")
            }

            if !elementalDamages.isEmpty {
                DatabaseRecordSectionView(attributes: elementalDamageAttributes) {
                    Text("Elemental Damage", tableName: "Database")
                }
            }

            if let raceGroups = monster.localizedRaceGroups {
                DatabaseRecordSectionView(tags: raceGroups) {
                    Text("Race Groups", tableName: "Database")
                }
            }

            if let modes = monster.localizedModes {
                DatabaseRecordSectionView(tags: modes) {
                    Text("Modes", tableName: "Database")
                }
            }

            if !mvpDropItems.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(mvpDropItems) { dropItem in
                            NavigationLink(value: dropItem.item) {
                                ItemCell(item: dropItem.item, badges: dropItem.badges)
                            }
                        }
                    }
                } header: {
                    Text("MVP Drops", tableName: "Database")
                }
            }

            if !dropItems.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(dropItems) { dropItem in
                            NavigationLink(value: dropItem.item) {
                                ItemCell(item: dropItem.item, badges: dropItem.badges)
                            }
                        }
                    }
                } header: {
                    Text("Drops", tableName: "Database")
                }
            }

            if !castSkills.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(castSkills) { castSkill in
                            NavigationLink(value: castSkill.skill) {
                                SkillCell(skill: castSkill.skill, badges: castSkill.badges)
                            }
                        }
                    }
                } header: {
                    Text("Skills", tableName: "Database")
                }
            }

            if !spawnMaps.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(spawnMaps) { spawnMap in
                            NavigationLink(value: spawnMap.map) {
                                MapCell(map: spawnMap.map, badges: spawnMap.badges)
                            }
                        }
                    }
                } header: {
                    Text("Maps", tableName: "Database")
                }
            }
        }
        .navigationTitle(monster.displayName)
        .task {
            await monster.fetchAnimatedImage()
        }
        .task {
            elementalDamages = await database.elementalDamages(for: monster)
        }
        .task {
            if let mvpDrops = monster.mvpDrops {
                mvpDropItems = await database.dropItems(for: mvpDrops)
            }
        }
        .task {
            if let drops = monster.drops {
                dropItems = await database.dropItems(for: drops)
            }
        }
        .task {
            castSkills = await database.monsterCastSkills(for: monster)
        }
        .task {
            let monster = (monster.id, monster.aegisName)
            spawnMaps = await database.spawnMaps(for: monster)
        }
    }

    private var elementalDamageAttributes: [DatabaseRecordAttribute] {
        elementalDamages.map { elementalDamage in
            DatabaseRecordAttribute(name: elementalDamage.attackElement.localizedName, value: formatRate(elementalDamage.rate, base: 100))
        }
    }
}
