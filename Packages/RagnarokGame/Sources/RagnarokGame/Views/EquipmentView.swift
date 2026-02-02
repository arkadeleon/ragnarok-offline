//
//  EquipmentView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/2/2.
//

import SwiftUI

struct EquipmentView: View {
    var body: some View {
        VStack(spacing: 0) {
            GameTitleBar()

            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    EquipmentLeftSlotRow(label: "head")
                    EquipmentSlotDivider()
                    EquipmentLeftSlotRow(label: "head")
                    EquipmentSlotDivider()
                    EquipmentLeftSlotRow(label: "R-hand")
                    EquipmentSlotDivider()
                    EquipmentLeftSlotRow(label: "robe")
                    EquipmentSlotDivider()
                    EquipmentLeftSlotRow(label: "acc.1")
                }
                .frame(width: 120)

                EquipmentCharacterView()

                VStack(spacing: 0) {
                    EquipmentRightSlotRow(label: "head")
                    EquipmentSlotDivider()
                    EquipmentRightSlotRow(label: "body")
                    EquipmentSlotDivider()
                    EquipmentRightSlotRow(label: "L-hand")
                    EquipmentSlotDivider()
                    EquipmentRightSlotRow(label: "shoes")
                    EquipmentSlotDivider()
                    EquipmentRightSlotRow(label: "acc.2")
                }
                .frame(width: 120)
            }
            .frame(height: 134)
            .background(Color.white)
            .overlay(alignment: .leading) {
                Rectangle().fill(Color.gameBoxBorder).frame(width: 1)
            }
            .overlay(alignment: .trailing) {
                Rectangle().fill(Color.gameBoxBorder).frame(width: 1)
            }

            GameBottomBar()
        }
        .frame(width: 320)
    }
}

private struct EquipmentCharacterView: View {
    var body: some View {
        ZStack {
            EquipmentCharacterBackground()
            EquipmentCharacterShadow()
                .offset(y: 50)
        }
    }
}

private struct EquipmentCharacterBackground: View {
    var body: some View {
        GeometryReader { geometry in
            let stripeCount = max(0, Int((geometry.size.height + 2) / 4))

            VStack(spacing: 2) {
                ForEach(0..<stripeCount, id: \.self) { _ in
                    Color(#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)).frame(height: 2)
                }
            }
        }
    }
}

private struct EquipmentCharacterShadow: View {
    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    stops: [
                        .init(color: Color(#colorLiteral(red: 0.5725490196, green: 0.5725490196, blue: 0.5725490196, alpha: 1)).opacity(0.9), location: 0),
                        .init(color: Color(#colorLiteral(red: 0.6862745098, green: 0.6862745098, blue: 0.6862745098, alpha: 1)).opacity(0.55), location: 0.55),
                        .init(color: Color(#colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)).opacity(0.0), location: 1)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 38
                )
            )
            .frame(width: 38, height: 24)
            .blendMode(.multiply)
    }
}

private struct EquipmentLeftSlotRow: View {
    var label: String

    var body: some View {
        HStack(spacing: 4) {
            EquipmentSlotImage()

            Text(label)
                .font(.game(size: 10))
                .foregroundStyle(Color(#colorLiteral(red: 0.8823529412, green: 0.8941176471, blue: 0.9137254902, alpha: 1)))
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(y: 5)
        }
        .padding(.horizontal, 4)
        .frame(height: 26)
    }
}

private struct EquipmentRightSlotRow: View {
    var label: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.game(size: 10))
                .foregroundStyle(Color(#colorLiteral(red: 0.8823529412, green: 0.8941176471, blue: 0.9137254902, alpha: 1)))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(y: 5)

            EquipmentSlotImage()
        }
        .padding(.horizontal, 4)
        .frame(height: 26)
    }
}

private struct EquipmentSlotImage: View {
    var body: some View {
        ZStack {
            EquipmentSlotShadow()
                .offset(y: 5)
        }
        .frame(width: 26, height: 26)
    }
}

private struct EquipmentSlotShadow: View {
    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    stops: [
                        .init(color: Color(#colorLiteral(red: 0.7294117647, green: 0.7725490196, blue: 0.8549019608, alpha: 1)).opacity(0.9), location: 0),
                        .init(color: Color(#colorLiteral(red: 0.7176470588, green: 0.7607843137, blue: 0.8470588235, alpha: 1)).opacity(0.55), location: 0.55),
                        .init(color: Color(#colorLiteral(red: 0.7450980392, green: 0.7843137255, blue: 0.8588235294, alpha: 1)).opacity(0.0), location: 1)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 18
                )
            )
            .frame(width: 18, height: 9)
    }
}

private struct EquipmentSlotDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.gameBoxBorder)
            .frame(height: 1)
            .padding(.horizontal, 6)
    }
}

#Preview {
    EquipmentView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
