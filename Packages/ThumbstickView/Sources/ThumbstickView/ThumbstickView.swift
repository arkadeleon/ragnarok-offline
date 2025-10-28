/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view for thumbstick control.
*/

import SwiftUI

/// A SwiftUI view that renders a virtual thumbstick control for directional input.
///
/// `ThumbStickView` displays a circular joystick-like UI with an outer boundary and a movable inner circle.
/// You can drag the inner circle to simulate directional input, and the view updates a bound `CGPoint`
/// representing the direction and magnitude of movement.
///
/// This is particularly useful in games, simulators, or any interactive app requiring analog-style input.
///
/// ```swift
/// @State private var joystickValue: CGPoint = .zero
///
/// var body: some View {
///     ThumbStickView(updatingValue: $joystickValue, radius: 60)
/// }
/// ```
///
/// The `updatingValue` binding updates with the offset from the center,
/// allowing you to interpret it as velocity, direction, and so forth.
///
/// - Note: The coordinate values in `updatingValue` are relative to the center of the joystick.
///   They reset to zero when the drag gesture ends.
///
/// - Parameters:
///   - updatingValue: A binding to a `CGPoint` that receives continuous updates based on user interaction.
///   - radius: The radius of the outer (static) circle. The inner circle automatically sets to half of this.
public struct ThumbstickView: View {
    // MARK: - Properties

    private let largeRadius: CGFloat
    private let smallerRadius: CGFloat

    @Binding private var updatingValue: CGPoint
    @State private var innerCircleLocation: CGPoint = .zero

    private var smallCircleCenter: CGPoint {
        CGPoint(x: largeRadius - smallerRadius, y: largeRadius - smallerRadius)
    }

    // MARK: - Initializer

    public init(updatingValue: Binding<CGPoint>, radius: CGFloat = 75) {
        self.largeRadius = radius
        self.smallerRadius = radius / 2
        self._updatingValue = updatingValue
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            outerCircle
                .overlay {
                    // The inner movable circle.
                    Circle()
                        .foregroundColor(.clear)
                        .background(.regularMaterial)
                        .cornerRadius(smallerRadius)
                        .position(innerCircleLocation)
                        .frame(width: smallerRadius * 2, height: smallerRadius * 2)
                        .gesture(fingerDrag)
                }
        }
        .onAppear { resetThumbstick() }
        .onChange(of: innerCircleLocation) { _, newValue in
            updatingValue = CGPoint(
                x: newValue.x - smallCircleCenter.x,
                y: newValue.y - smallCircleCenter.y
            )
        }
    }

    // The outer circle.
    @ViewBuilder private var outerCircle: some View {
        if #available(macOS 26.0, iOS 26.0, visionOS 26.0, *) {
            Color.clear
                .frame(width: largeRadius * 2, height: largeRadius * 2)
                .glassEffect(.regular, in: .circle)
        } else {
            Color.clear
                .frame(width: largeRadius * 2, height: largeRadius * 2)
                .background(.ultraThinMaterial)
                .cornerRadius(largeRadius)
        }
    }

    // MARK: - Gesture

    private var fingerDrag: some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                let translation = value.translation
                let distance = hypot(translation.width, translation.height)
                let angle = atan2(translation.height, translation.width)
                let maxDistance = smallCircleCenter.x
                let clampedDistance = min(distance, maxDistance)

                let newX = cos(angle) * clampedDistance + maxDistance
                let newY = sin(angle) * clampedDistance + maxDistance

                innerCircleLocation = CGPoint(x: newX, y: newY)
            }
            .onEnded { _ in resetThumbstick() }
    }

    // MARK: - Helpers

    private func resetThumbstick() {
        innerCircleLocation = smallCircleCenter
    }
}
