//
//  ThumbstickView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/9.
//

#if canImport(UIKit)

import UIKit

final class ThumbstickView: UIView {
    static let radius: CGFloat = 75

    /// How far the knob can move from the center.
    static let knobTravel: CGFloat = radius / 2

    private let knobView = UIView()

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: Self.radius * 2, height: Self.radius * 2))

        isUserInteractionEnabled = false
        isHidden = true
        backgroundColor = #colorLiteral(red: 0.7568627451, green: 0.7568627451, blue: 0.7568627451, alpha: 0.3296931004)
        layer.cornerRadius = Self.radius

        let knobRadius = Self.radius / 2
        knobView.frame = CGRect(x: 0, y: 0, width: knobRadius * 2, height: knobRadius * 2)
        knobView.layer.shadowOpacity = 0.3
        knobView.layer.shadowRadius = 5
        knobView.layer.shadowOffset = .zero

        let materialView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        materialView.frame = knobView.bounds
        materialView.layer.cornerRadius = knobRadius
        materialView.clipsToBounds = true
        knobView.addSubview(materialView)

        addSubview(knobView)
        knobView.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(at point: CGPoint) {
        center = point
        knobView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        isHidden = false
    }

    func moveKnob(by offset: CGPoint) {
        knobView.center = CGPoint(x: bounds.midX + offset.x, y: bounds.midY + offset.y)
    }
}

#endif
