//
//  CharacterMakeView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/9/10.
//

import RagnarokModels
import RagnarokSprite
import SwiftUI

struct CharacterMakeView: View {
    var slot: Int

    @Environment(GameSession.self) private var gameSession

    @State private var character = CharacterInfo()
    @State private var characterAnimation: SpriteRenderer.Animation?
    @State private var startDate: Date = .now

    var body: some View {
        GameWindow {
            ZStack(alignment: .bottomTrailing) {
                HStack(alignment: .top, spacing: 0) {
                    CharacterPreviewPanel(
                        character: $character,
                        animation: characterAnimation,
                        startDate: startDate
                    )
                    .padding(.bottom, 52)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

                    StatHexagonPanel(character: $character)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                    StatTablePanel(character: character)
                        .padding(.top, 22)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }

                VStack(alignment: .trailing, spacing: -6) {
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("Make")
                            .font(.system(size: 36, weight: .black))
                            .italic()
                        Text("Your")
                            .font(.system(size: 20, weight: .bold))
                            .italic()
                    }
                    Text("Characters")
                        .font(.system(size: 32, weight: .black))
                        .italic()
                }
                .foregroundStyle(Color(red: 0.42, green: 0.51, blue: 0.66, opacity: 0.88))
                .padding(.trailing, 10)
                .padding(.bottom, 10)
            }
            .background {
                GameVineBackground()
            }
        } bottomBar: {
            GameBottomBar {
                Button("make") {
                    gameSession.createCharacter(character)
                }
                .buttonStyle(.game)
                .frame(width: 42, height: 20)
                .disabled(character.name.isEmpty)

                Button("cancel") {
                    gameSession.exitCurrentPhase()
                }
                .buttonStyle(.game)
                .frame(width: 42, height: 20)
            }
        }
        .frame(width: 576, height: 342)
        .task {
            character.job = 0
            character.head = 2
            character.headPalette = 0
            character.str = 5
            character.agi = 5
            character.vit = 5
            character.int = 5
            character.dex = 5
            character.luk = 5
            character.charNum = slot

            if let account = gameSession.account {
                character.sex = account.sex
            }
        }
        .task(id: "\(character.head), \(character.headPalette)") {
            let directions = SpriteDirection.allCases
            var directionIndex = 0
            while !Task.isCancelled {
                let direction = directions[directionIndex % directions.count]
                if let characterAnimation = await gameSession.characterAnimation(for: character, direction: direction) {
                    self.characterAnimation = characterAnimation
                    startDate = .now
                }
                try? await Task.sleep(for: .seconds(1))
                directionIndex += 1
            }
        }
    }
}

// MARK: - Character Preview Panel

private struct CharacterPreviewPanel: View {
    @Binding var character: CharacterInfo
    var animation: SpriteRenderer.Animation?
    var startDate: Date

    var body: some View {
        VStack(spacing: 11) {
            ZStack {
                Ellipse()
                    .fill(Color(#colorLiteral(red: 0.5725490196, green: 0.5725490196, blue: 0.5725490196, alpha: 1)))
                    .blur(radius: 4)
                    .frame(width: 38, height: 24)
                    .offset(y: 42.5)

                Button {
                    character.headPalette = (character.headPalette + 1) % 10
                } label: {
                    GameUpArrow()
                        .fill(Color(#colorLiteral(red: 0.6666666667, green: 0.7294117647, blue: 0.8862745098, alpha: 1)))
                        .stroke(Color(#colorLiteral(red: 0.4588235294, green: 0.5490196078, blue: 0.8196078431, alpha: 1)), lineWidth: 1)
                        .frame(width: 13, height: 10)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .offset(y: -57.5)

                Button {
                    character.head = character.head <= 2 ? 26 : character.head - 1
                } label: {
                    GameLeftArrow()
                        .fill(Color(#colorLiteral(red: 0.6666666667, green: 0.7294117647, blue: 0.8862745098, alpha: 1)))
                        .stroke(Color(#colorLiteral(red: 0.4588235294, green: 0.5490196078, blue: 0.8196078431, alpha: 1)), lineWidth: 1)
                        .frame(width: 10, height: 13)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .offset(x: -40, y: -27.5)

                Button {
                    character.head = character.head >= 26 ? 2 : character.head + 1
                } label: {
                    GameRightArrow()
                        .fill(Color(#colorLiteral(red: 0.6666666667, green: 0.7294117647, blue: 0.8862745098, alpha: 1)))
                        .stroke(Color(#colorLiteral(red: 0.4588235294, green: 0.5490196078, blue: 0.8196078431, alpha: 1)), lineWidth: 1)
                        .frame(width: 10, height: 13)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .offset(x: 40, y: -27.5)

                TimelineView(.periodic(from: .now, by: 0.1)) { timelineContext in
                    Canvas { graphicsContext, size in
                        if let animation {
                            let frames = animation.frames
                            let frameInterval = Double(animation.frameInterval)
                            let elapsed = timelineContext.date.timeIntervalSince(startDate)
                            let frameIndex = Int(elapsed / frameInterval) % frames.count
                            if frames.indices.contains(frameIndex), let frame = frames[frameIndex] {
                                let image = Image(decorative: frame, scale: 2)
                                var rect = CGRect(x: 0, y: 0, width: animation.frameWidth, height: animation.frameHeight)
                                rect.origin.x = (size.width - animation.frameWidth) / 2
                                rect.origin.y = (size.height - animation.frameHeight) / 2
                                graphicsContext.draw(image, in: rect)
                            }
                        }
                    }
                }
                .frame(width: 65, height: 110)
                .offset(y: 6)
            }
            .frame(width: 128, height: 128)

            HStack(spacing: 4) {
                Text(verbatim: "Name")
                    .font(.game(weight: .bold))
                    .foregroundStyle(Color.gameProminentLabel)

                TextField(String(), text: $character.name)
                    .textFieldStyle(.plain)
                    #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .disableAutocorrection(true)
                    .font(.game())
                    .foregroundStyle(Color.gameLabel)
                    .padding(.horizontal, 3)
                    .frame(width: 101, height: 18)
                    .background(Color.gameSecondaryBoxBackground)
                    .overlay {
                        Rectangle().strokeBorder(Color.gameBoxBorder, lineWidth: 1)
                    }
            }
        }
    }
}

// MARK: - Stat Hexagon Panel

private struct StatHexagonPanel: View {
    @Binding var character: CharacterInfo

    private let statButtonRadius: CGFloat = 97
    private var statButtonDiagonalX: CGFloat {
        statButtonRadius * CGFloat(sin(Double.pi / 3))
    }
    private var statButtonDiagonalY: CGFloat {
        statButtonRadius * CGFloat(cos(Double.pi / 3))
    }

    var body: some View {
        ZStack(alignment: .center) {
            Canvas { context, size in
                let r = size.height / 2
                let sin60 = CGFloat(sin(60.0 * Double.pi / 180))
                let cos60 = CGFloat(cos(60.0 * Double.pi / 180))
                let cx = size.width / 2
                let cy = size.height / 2
                let center = CGPoint(x: cx, y: cy)
                let vertices: [CGPoint] = [
                    CGPoint(x: cx, y: cy - r),
                    CGPoint(x: cx - r * sin60, y: cy - r * cos60),
                    CGPoint(x: cx - r * sin60, y: cy + r * cos60),
                    CGPoint(x: cx, y: cy + r),
                    CGPoint(x: cx + r * sin60, y: cy + r * cos60),
                    CGPoint(x: cx + r * sin60, y: cy - r * cos60),
                ]
                let lineColor = Color(#colorLiteral(red: 0.369, green: 0.502, blue: 0.749, alpha: 1.0))
                for v in vertices {
                    var path = Path()
                    path.move(to: center)
                    path.addLine(to: v)
                    context.stroke(path, with: .color(lineColor), lineWidth: 1)
                }
                var hexPath = Path()
                hexPath.move(to: vertices[0])
                for v in vertices.dropFirst() { hexPath.addLine(to: v) }
                hexPath.closeSubpath()
                context.stroke(hexPath, with: .color(lineColor), lineWidth: 1)
            }
            .frame(width: 158, height: 158)

            Canvas { context, size in
                let str = Double(character.str + 1) / 10 * size.height / 2
                let agi = Double(character.agi + 1) / 10 * size.height / 2
                let vit = Double(character.vit + 1) / 10 * size.height / 2
                let int = Double(character.int + 1) / 10 * size.height / 2
                let dex = Double(character.dex + 1) / 10 * size.height / 2
                let luk = Double(character.luk + 1) / 10 * size.height / 2

                let sin60: Double = sin(60 * .pi / 180)
                let cos60: Double = cos(60 * .pi / 180)

                context.translateBy(x: size.width / 2, y: size.height / 2)

                var path = Path()
                path.move(to: CGPoint(x: 0, y: -str))
                path.addLine(to: CGPoint(x: -agi * sin60, y: -agi * cos60))
                path.addLine(to: CGPoint(x: -dex * sin60, y: dex * cos60))
                path.addLine(to: CGPoint(x: 0, y: int))
                path.addLine(to: CGPoint(x: luk * sin60, y: luk * cos60))
                path.addLine(to: CGPoint(x: vit * sin60, y: -vit * cos60))
                path.closeSubpath()

                context.fill(path, with: .color(Color(#colorLiteral(red: 0.4823529412, green: 0.5803921569, blue: 0.8078431373, alpha: 1))))
            }
            .frame(width: 158, height: 158)

            StatArrowButton("STR") {
                if character.str < 9 && character.int > 1 {
                    character.str += 1
                    character.int -= 1
                }
            }
            .frame(width: 36, height: 36)
            .offset(y: -statButtonRadius)

            StatArrowButton("AGI", rotation: .degrees(-60)) {
                if character.agi < 9 && character.luk > 1 {
                    character.agi += 1
                    character.luk -= 1
                }
            }
            .frame(width: 36, height: 36)
            .offset(x: -statButtonDiagonalX, y: -statButtonDiagonalY)

            StatArrowButton("VIT", rotation: .degrees(60)) {
                if character.vit < 9 && character.dex > 1 {
                    character.vit += 1
                    character.dex -= 1
                }
            }
            .frame(width: 36, height: 36)
            .offset(x: statButtonDiagonalX, y: -statButtonDiagonalY)

            StatArrowButton("INT", rotation: .degrees(180)) {
                if character.int < 9 && character.str > 1 {
                    character.int += 1
                    character.str -= 1
                }
            }
            .frame(width: 36, height: 36)
            .offset(y: statButtonRadius)

            StatArrowButton("DEX", rotation: .degrees(-120)) {
                if character.dex < 9 && character.vit > 1 {
                    character.dex += 1
                    character.vit -= 1
                }
            }
            .frame(width: 36, height: 36)
            .offset(x: -statButtonDiagonalX, y: statButtonDiagonalY)

            StatArrowButton("LUK", rotation: .degrees(120)) {
                if character.luk < 9 && character.agi > 1 {
                    character.luk += 1
                    character.agi -= 1
                }
            }
            .frame(width: 36, height: 36)
            .offset(x: statButtonDiagonalX, y: statButtonDiagonalY)
        }
        .frame(width: 192, height: 230)
    }
}

// MARK: - Stat Table Panel

private struct StatTablePanel: View {
    var character: CharacterInfo

    var body: some View {
        VStack(spacing: 1) {
            ForEach(stats, id: \.0) { label, value in
                HStack(spacing: 0) {
                    Text(verbatim: label)
                        .font(.game(weight: .bold))
                        .foregroundStyle(Color.gameProminentLabel)
                        .padding(.leading, 3)
                        .frame(width: 48, height: 15, alignment: .leading)
                        .background(Color(#colorLiteral(red: 0.773, green: 0.812, blue: 0.89, alpha: 1)))
                    Text(verbatim: value)
                        .font(.game())
                        .foregroundStyle(Color.gameLabel)
                        .frame(width: 95, height: 15)
                        .background(Color(#colorLiteral(red: 0.914, green: 0.937, blue: 0.969, alpha: 1)))
                }
            }
        }
    }

    private var stats: [(String, String)] {
        [
            ("STR", character.str.formatted()),
            ("AGI", character.agi.formatted()),
            ("VIT", character.vit.formatted()),
            ("INT", character.int.formatted()),
            ("DEX", character.dex.formatted()),
            ("LUK", character.luk.formatted()),
        ]
    }
}

// MARK: - Stat Arrow Button

private struct StatArrowButton: View {
    var label: String
    var rotation: Angle
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                ZStack {
                    GameTriangle()
                        .fill(Color(#colorLiteral(red: 0.7725490196, green: 0.8117647059, blue: 0.8901960784, alpha: 1)))
                        .stroke(Color(#colorLiteral(red: 0.4980392157, green: 0.5607843137, blue: 0.6941176471, alpha: 1)), lineWidth: 1)
                }
                .frame(width: 18, height: 16)

                Text(verbatim: label)
                    .font(.game(size: 9))
                    .foregroundStyle(Color.gameProminentLabel)
            }
            .rotationEffect(rotation)
            .frame(width: 36, height: 36)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    init(_ label: String, rotation: Angle = .zero, action: @escaping () -> Void) {
        self.label = label
        self.rotation = rotation
        self.action = action
    }
}

#Preview {
    CharacterMakeView(slot: 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
