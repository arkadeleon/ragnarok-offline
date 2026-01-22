//
//  StatusView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/8.
//

import SwiftUI

struct StatusView: View {
    var status: CharacterStatus

    @Environment(GameSession.self) private var gameSession

    var body: some View {
        VStack(spacing: 0) {
            GameTitleBar()

            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: 2) {
                    PrimaryStatRow("Str", value: status.str, value2: status.str2, value3: status.str3) {
                        gameSession.incrementStatusProperty(.str, by: 1)
                    }
                    PrimaryStatRow("Agi", value: status.agi, value2: status.agi2, value3: status.agi3) {
                        gameSession.incrementStatusProperty(.agi, by: 1)
                    }
                    PrimaryStatRow("Vit", value: status.vit, value2: status.vit2, value3: status.vit3) {
                        gameSession.incrementStatusProperty(.vit, by: 1)
                    }
                    PrimaryStatRow("Int", value: status.int, value2: status.int2, value3: status.int3) {
                        gameSession.incrementStatusProperty(.int, by: 1)
                    }
                    PrimaryStatRow("Dex", value: status.dex, value2: status.dex2, value3: status.dex3) {
                        gameSession.incrementStatusProperty(.dex, by: 1)
                    }
                    PrimaryStatRow("Luk", value: status.luk, value2: status.luk2, value3: status.luk3) {
                        gameSession.incrementStatusProperty(.luk, by: 1)
                    }
                }
                .padding(.leading, 6)

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            SecondaryStatRow("Atk", value: "\(status.atk)")
                            SecondaryStatRow("Matk", value: "\(status.matk)")
                            SecondaryStatRow("Hit", value: "\(status.hit)")
                            SecondaryStatRow("Critical", value: "\(status.critical)")
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            SecondaryStatRow("Def", value: "\(status.def)")
                            SecondaryStatRow("Mdef", value: "\(status.mdef)")
                            SecondaryStatRow("Flee", value: "\(status.flee)")
                            SecondaryStatRow("Aspd", value: "\(status.aspd)")
                        }
                    }

                    SecondaryStatRow("Status Point", value: "\(status.statusPoint)")
                    SecondaryStatRow("Guild", value: "")
                }
                .padding(.trailing, 6)
            }
            .padding(.vertical, 6)
            .background(Color.white)
            .overlay(alignment: .leading) {
                Rectangle().fill(Color.gameBoxBorder).frame(width: 1)
            }
            .overlay(alignment: .trailing) {
                Rectangle().fill(Color.gameBoxBorder).frame(width: 1)
            }

            GameBottomBar()
        }
        .frame(width: 280)
    }
}

private struct PrimaryStatRow: View {
    var title: String
    var value: Int
    var value2: Int
    var value3: Int
    var onIncrement: () -> Void

    var body: some View {
        HStack(spacing: 2) {
            Text(title)
                .font(.game(weight: .bold))
                .foregroundStyle(Color.gameProminentLabel)
                .frame(width: 24, alignment: .leading)

            HStack(spacing: 0) {
                Text("\(value)")
                    .font(.game())
                    .foregroundStyle(Color.gameLabel)
                    .frame(width: 24, height: 12)
                Text("+\(value2)")
                    .font(.game())
                    .foregroundStyle(Color.gameLabel)
                    .frame(width: 24, height: 12)
            }
            .background(Color.gameSecondaryBoxBackground)
            .overlay(Rectangle().strokeBorder(Color.gameBoxBorder, lineWidth: 1))

            Button(action: onIncrement) {
                RightArrow()
                    .fill(Color(#colorLiteral(red: 0.6666666667, green: 0.7294117647, blue: 0.8862745098, alpha: 1)))
                    .stroke(Color(#colorLiteral(red: 0.4588235294, green: 0.5490196078, blue: 0.8196078431, alpha: 1)), lineWidth: 1)
                    .frame(width: 6, height: 8)
            }
            .buttonStyle(.plain)
            .frame(width: 14, height: 12)
            .background(Color.gameSecondaryBoxBackground)
            .overlay(Rectangle().strokeBorder(Color.gameBoxBorder, lineWidth: 1))

            Text("\(value3)")
                .font(.game())
                .foregroundStyle(Color.gameLabel)
                .frame(width: 20, height: 12, alignment: .trailing)
                .background(Color.white)
                .overlay(Rectangle().strokeBorder(Color.gameBoxBorder, lineWidth: 1))
        }
        .frame(height: 14)
    }

    init(_ title: String, value: Int, value2: Int, value3: Int, onIncrement: @escaping () -> Void) {
        self.title = title
        self.value = value
        self.value2 = value2
        self.value3 = value3
        self.onIncrement = onIncrement
    }
}

private struct SecondaryStatRow: View {
    var title: String
    var value: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.game(weight: .bold))
                    .foregroundStyle(Color.gameProminentLabel)

                Spacer()

                Text(value)
                    .font(.game())
                    .foregroundStyle(Color.gameLabel)
            }

            Rectangle()
                .fill(Color.gameBoxBorder)
                .frame(height: 1)
        }
        .frame(height: 14)
    }

    init(_ title: String, value: String) {
        self.title = title
        self.value = value
    }
}

private struct RightArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    StatusView(status: CharacterStatus())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
