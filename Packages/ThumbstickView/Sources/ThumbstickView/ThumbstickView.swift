/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view for thumbstick control.
*/

import SwiftUI

/// A virtual thumbstick: drag anywhere in the circle to move the inner knob,
/// which snaps back to center on release.
///
/// ```swift
/// @State private var joystickValue: CGPoint = .zero
///
/// var body: some View {
///     ThumbstickView(value: $joystickValue, radius: 60)
/// }
/// ```
///
/// - Parameters:
///   - value: Offset of the knob from center, updated continuously while dragging and reset to zero on release.
///   - radius: The radius of the outer circle. The inner knob is half of this.
public struct ThumbstickView: View {
    private let largeRadius: CGFloat
    private let smallerRadius: CGFloat

    @Binding private var value: CGPoint

    @State private var innerCirclePosition: CGPoint = .zero

    public var body: some View {
        Circle()
            .fill(Color(#colorLiteral(red: 0.7568627451, green: 0.7568627451, blue: 0.7568627451, alpha: 0.3296931004)))
            .frame(width: largeRadius * 2, height: largeRadius * 2)
            .overlay {
                Circle()
                    .foregroundColor(.clear)
                    .background(.regularMaterial)
                    .cornerRadius(smallerRadius)
                    .shadow(radius: 5)
                    .position(innerCirclePosition)
                    .frame(width: smallerRadius * 2, height: smallerRadius * 2)
            }
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let offsetX = value.location.x - largeRadius
                        let offsetY = value.location.y - largeRadius
                        let distance = hypot(offsetX, offsetY)
                        let angle = atan2(offsetY, offsetX)
                        let maxDistance = smallCircleCenter.x
                        let clampedDistance = min(distance, maxDistance)

                        let newX = cos(angle) * clampedDistance + maxDistance
                        let newY = sin(angle) * clampedDistance + maxDistance

                        innerCirclePosition = CGPoint(x: newX, y: newY)
                    }
                    .onEnded { _ in
                        innerCirclePosition = smallCircleCenter
                    }
            )
            .onAppear {
                innerCirclePosition = smallCircleCenter
            }
            .onChange(of: innerCirclePosition) { _, newValue in
                value = CGPoint(
                    x: newValue.x - smallCircleCenter.x,
                    y: newValue.y - smallCircleCenter.y
                )
            }
    }

    private var smallCircleCenter: CGPoint {
        CGPoint(x: largeRadius - smallerRadius, y: largeRadius - smallerRadius)
    }

    public init(value: Binding<CGPoint>, radius: CGFloat = 75) {
        self.largeRadius = radius
        self.smallerRadius = radius / 2
        self._value = value
    }
}
