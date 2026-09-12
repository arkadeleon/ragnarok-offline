//
//  ShortcutDrag.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/11.
//

import RagnarokModels
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Sources, targets, the native gesture location, and the preview all use this coordinate space.
private let coordinateSpaceName = "ShortcutDrag"

/// The preview is drawn above the pointer so that it is not hidden by the user's finger.
private let dragPreviewSize: CGFloat = 24
private let dragPreviewOffsetY: CGFloat = -24

/// Extends each slot upward and downward without making adjacent columns overlap.
private let dropTargetVerticalExpansion: CGFloat = 16

/// Moving beyond this tolerance before the delay expires gives scrolling a chance to win.
private let dragActivationDuration = 0.25
private let dragActivationMovement: CGFloat = 8

/*
 Shortcut drag flow

                    +-----------------------+
                    |     View appears      |
                    +-----------+-----------+
                                |
                                v
                    +-----------------------+
                    | Sources and targets   |
                    | register their frames |
                    +-----------+-----------+
                                |
                                v
                    +-----------------------+
                    | Touch or mouse down   |
                    +-----------+-----------+
                                |
                                v
                    +-----------------------+
                    | Did input hit a       |
                    | registered source?    |
                    +-----------+-----------+
                                |
                  +-------------+-------------+
                  | No                        | Yes
                  v                           v
       +----------------------+    +------------------------+
       | Recognizer ignores   |    | Capture source ID      |
       | this input stream    |    +-----------+------------+
       +----------------------+                |
                                               v
                                   +------------------------+
                                   | Moved more than 8 pt   |
                                   | before 0.25 seconds?   |
                                   +-----------+------------+
                                               |
                                 +-------------+-------------+
                                 | Yes                       | No
                                 v                           v
                    +------------------------+    +------------------------+
                    | Long press fails;      |    | Long press enters      |
                    | ScrollView takes over  |    | the began state        |
                    +------------------------+    +-----------+------------+
                                                             |
                                                             v
                                                 +------------------------+
                                                 | Create DragSession and |
                                                 | send haptic feedback   |
                                                 +-----------+------------+
                                                             |
                                                             v
                                                 +------------------------+
                                                 | changed updates the    |
                                                 | pointer location       |
                                                 +-----------+------------+
                                                             |
                                                             v
                                                 +------------------------+
                                                 | Update preview and     |
                                                 | target-slot highlight  |
                                                 +-----------+------------+
                                                             |
                                                             v
                                                 +------------------------+
                                                 | How did gesture end?   |
                                                 +-----------+------------+
                                                             |
                                               +-------------+-------------+
                                               | ended                     | cancelled / failed
                                               v                           v
                                   +------------------------+    +------------------------+
                                   | Create ShortcutDrop    |    | Clear DragSession only |
                                   +-----------+------------+    +------------------------+
                                               |
                                               v
                                   +------------------------+
                                   | Commit shortcut change |
                                   +------------------------+
 */

/// A stable address for one cell in the server-backed shortcut list.
struct ShortcutSlot: Hashable {
    var row: Int
    var column: Int
}

/// A source reports its payload and current bounds, but does not install its own gesture.
private struct ShortcutDragSourceRegistration {
    var shortcut: Shortcut
    /// `nil` for inventory items and skills; non-`nil` for an existing shortcut-bar item.
    var sourceSlot: ShortcutSlot?
    var frame: CGRect
}

/// A target carries the full row and column so row changes cannot race with a drop.
private struct ShortcutDropTargetRegistration {
    var slot: ShortcutSlot
    var frame: CGRect
}

/// The completed gesture operation passed from gesture state to the game session.
private struct ShortcutDrop {
    var shortcut: Shortcut
    var sourceSlot: ShortcutSlot?
    var targetSlot: ShortcutSlot?
}

/// An immutable payload snapshot plus the pointer location for an active drag.
private struct ShortcutDragSession {
    var shortcut: Shortcut
    var sourceSlot: ShortcutSlot?
    var location: CGPoint
}

@MainActor
@Observable
final class ShortcutDragState {
    /// UUIDs distinguish views whose shortcut values happen to be identical.
    private var sources: [UUID : ShortcutDragSourceRegistration] = [:]
    private var targets: [UUID : ShortcutDropTargetRegistration] = [:]

    /// `nil` means the native recognizer has not successfully begun a drag.
    private var session: ShortcutDragSession?

    var shortcut: Shortcut? {
        session?.shortcut
    }

    var location: CGPoint? {
        session?.location
    }

    /// The slot below the shortcut being dragged.
    var targetSlot: ShortcutSlot? {
        guard let location = session?.location else {
            return nil
        }

        return targets.values.first(where: { $0.frame.contains(location) })?.slot
    }

    func registerSource(
        id: UUID,
        shortcut: Shortcut,
        sourceSlot: ShortcutSlot?,
        frame: CGRect
    ) {
        guard shortcut != .empty else {
            sources[id] = nil
            return
        }

        sources[id] = ShortcutDragSourceRegistration(
            shortcut: shortcut,
            sourceSlot: sourceSlot,
            frame: frame
        )
    }

    func unregisterSource(id: UUID) {
        sources[id] = nil
    }

    func registerTarget(id: UUID, slot: ShortcutSlot, frame: CGRect) {
        targets[id] = ShortcutDropTargetRegistration(
            slot: slot,
            frame: frame.insetBy(dx: 0, dy: -dropTargetVerticalExpansion)
        )
    }

    func unregisterTarget(id: UUID) {
        targets[id] = nil
    }

    func sourceID(at location: CGPoint) -> UUID? {
        sources.first(where: { $0.value.frame.contains(location) })?.key
    }

    /// Begins a drag using the source ID captured when the press first arrived. Looking it up
    /// again prevents a source removed during the activation delay from starting a stale drag.
    func begin(sourceID: UUID, at location: CGPoint) -> Bool {
        guard let source = sources[sourceID] else {
            return false
        }

        session = ShortcutDragSession(
            shortcut: source.shortcut,
            sourceSlot: source.sourceSlot,
            location: location
        )
        return true
    }

    func drag(to location: CGPoint) {
        session?.location = location
    }

    /// Finishes a successfully recognized drag and returns the business operation to commit.
    /// Target hit testing uses the real pointer location, not the offset preview.
    fileprivate func finish(at location: CGPoint) -> ShortcutDrop? {
        guard var session else {
            return nil
        }

        session.location = location
        let targetSlot = targets.values.first(where: { $0.frame.contains(location) })?.slot
        self.session = nil

        return ShortcutDrop(
            shortcut: session.shortcut,
            sourceSlot: session.sourceSlot,
            targetSlot: targetSlot
        )
    }

    /// Cancelling recognition only removes transient UI state and never mutates the shortcut list.
    func cancel() {
        session = nil
    }
}

extension View {
    /// Lets the shortcuts inside the content be dragged to the shortcut bar it contains.
    func shortcutDragContainer() -> some View {
        modifier(ShortcutDragContainer())
    }

    /// Registers `shortcut` as a drag source without installing a gesture on this view.
    func shortcutDragSource(_ shortcut: Shortcut, from sourceSlot: ShortcutSlot? = nil) -> some View {
        modifier(ShortcutDragSource(shortcut: shortcut, sourceSlot: sourceSlot))
    }

    /// Registers `slot` as a drop target without installing a gesture on this view.
    func shortcutDropTarget(_ slot: ShortcutSlot) -> some View {
        modifier(ShortcutDropTarget(slot: slot))
    }
}

private struct ShortcutDragContainer: ViewModifier {
    @Environment(GameSession.self) private var gameSession

    /// One container owns one drag state shared by all of its sources and targets.
    @State private var dragState = ShortcutDragState()

    func body(content: Content) -> some View {
        content
            .environment(dragState)
            .coordinateSpace(.named(coordinateSpaceName))
            .background {
                // The bridge observes native pointer events without becoming a hit-testable overlay.
                ShortcutDragGestureBridge(state: dragState, onDrop: commit)
            }
            .overlay {
                if let shortcut = dragState.shortcut, let location = dragState.location {
                    ShortcutIconView(shortcut: shortcut)
                        .frame(width: dragPreviewSize, height: dragPreviewSize)
                        // Only the preview moves upward; target detection keeps using `location`.
                        .position(x: location.x, y: location.y + dragPreviewOffsetY)
                        .allowsHitTesting(false)
                }
            }
            #if !os(visionOS)
            .sensoryFeedback(.impact, trigger: dragState.shortcut != nil) { _, isDragging in
                isDragging
            }
            #endif
    }

    private func commit(_ drop: ShortcutDrop) {
        // Returning to the source cell does not generate packets or visible state changes.
        guard drop.targetSlot != drop.sourceSlot else {
            return
        }

        switch (drop.sourceSlot, drop.targetSlot) {
        case (nil, nil):
            // Inventory and skill-list drags dropped outside the bar are ignored.
            break
        case (let sourceSlot?, nil):
            // Dragging an existing shortcut outside the bar removes it.
            gameSession.removeShortcut(atRow: sourceSlot.row, column: sourceSlot.column)
        case (nil, let targetSlot?):
            // A new inventory item or skill is assigned to the destination.
            gameSession.setShortcut(drop.shortcut, atRow: targetSlot.row, column: targetSlot.column)
        case (let sourceSlot?, let targetSlot?):
            // A bar-to-bar move is committed atomically by GameSession.
            gameSession.moveShortcut(
                drop.shortcut,
                fromRow: sourceSlot.row,
                column: sourceSlot.column,
                toRow: targetSlot.row,
                column: targetSlot.column
            )
        }
    }
}

private struct ShortcutDragSource: ViewModifier {
    var shortcut: Shortcut
    var sourceSlot: ShortcutSlot?

    @Environment(ShortcutDragState.self) private var dragState

    /// `@State` keeps the registration identity stable across SwiftUI body updates.
    @State private var registrationID = UUID()
    @State private var frame: CGRect?

    func body(content: Content) -> some View {
        content
            // Geometry changes include layout, scrolling, and window movement.
            .onGeometryChange(for: CGRect.self) { geometryProxy in
                geometryProxy.frame(in: .named(coordinateSpaceName))
            } action: { frame in
                self.frame = frame
                register(frame: frame)
            }
            .onChange(of: shortcut, initial: true) {
                // Content can change while its geometry remains exactly the same.
                if let frame {
                    register(frame: frame)
                }
            }
            .onChange(of: sourceSlot, initial: true) {
                // Switching shortcut-bar rows can also leave the cell frame unchanged.
                if let frame {
                    register(frame: frame)
                }
            }
            .onDisappear {
                // Lazy containers discard off-screen views, so stale frames must be removed.
                dragState.unregisterSource(id: registrationID)
            }
    }

    private func register(frame: CGRect) {
        dragState.registerSource(
            id: registrationID,
            shortcut: shortcut,
            sourceSlot: sourceSlot,
            frame: frame
        )
    }
}

private struct ShortcutDropTarget: ViewModifier {
    var slot: ShortcutSlot

    @Environment(ShortcutDragState.self) private var dragState

    /// Targets also need per-view identity so replacement views cannot unregister each other.
    @State private var registrationID = UUID()
    @State private var frame: CGRect?

    func body(content: Content) -> some View {
        content
            // Use the same coordinate space as source registration and native pointer locations.
            .onGeometryChange(for: CGRect.self) { geometryProxy in
                geometryProxy.frame(in: .named(coordinateSpaceName))
            } action: { frame in
                self.frame = frame
                dragState.registerTarget(id: registrationID, slot: slot, frame: frame)
            }
            .onChange(of: slot, initial: true) {
                // The row may change without changing the shortcut bar's geometry.
                if let frame {
                    dragState.registerTarget(id: registrationID, slot: slot, frame: frame)
                }
            }
            .onDisappear {
                dragState.unregisterTarget(id: registrationID)
            }
    }
}

#if canImport(UIKit)
/// Installs one continuous native long-press recognizer for every source in the container.
private struct ShortcutDragGestureBridge: UIViewRepresentable {
    var state: ShortcutDragState
    var onDrop: (ShortcutDrop) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(state: state, onDrop: onDrop)
    }

    func makeUIView(context: Context) -> ShortcutDragCaptureUIView {
        let view = ShortcutDragCaptureUIView()
        // The view is only a coordinate reference. SwiftUI content remains responsible for hits.
        view.isUserInteractionEnabled = false
        view.windowDidChange = { [weak coordinator = context.coordinator] window in
            coordinator?.attach(to: window)
        }
        context.coordinator.captureView = view
        return view
    }

    func updateUIView(_ uiView: ShortcutDragCaptureUIView, context: Context) {
        context.coordinator.state = state
        context.coordinator.onDrop = onDrop
        context.coordinator.attach(to: uiView.window)
    }

    static func dismantleUIView(_ uiView: ShortcutDragCaptureUIView, coordinator: Coordinator) {
        coordinator.detach()
    }

    @MainActor
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var state: ShortcutDragState
        var onDrop: (ShortcutDrop) -> Void
        weak var captureView: UIView?

        private weak var installedView: UIView?

        /// Captured on touch-down so slight movement during the delay cannot select a neighbor.
        private var pendingSourceID: UUID?

        private lazy var recognizer: UILongPressGestureRecognizer = {
            let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
            recognizer.minimumPressDuration = dragActivationDuration
            recognizer.allowableMovement = dragActivationMovement
            recognizer.numberOfTouchesRequired = 1
            // Deliver ordinary touch-down events immediately. Once the long press begins, cancel
            // the underlying tap or button so the same interaction cannot both tap and drag.
            recognizer.cancelsTouchesInView = true
            recognizer.delaysTouchesBegan = false
            recognizer.delegate = self
            return recognizer
        }()

        init(state: ShortcutDragState, onDrop: @escaping (ShortcutDrop) -> Void) {
            self.state = state
            self.onDrop = onDrop
        }

        func attach(to window: UIWindow?) {
            guard installedView !== window else {
                return
            }

            installedView?.removeGestureRecognizer(recognizer)
            installedView = window
            // A representable used as a background can be a sibling of the rendered SwiftUI
            // content. Installing on the window observes the whole subtree reliably.
            window?.addGestureRecognizer(recognizer)
        }

        func detach() {
            installedView?.removeGestureRecognizer(recognizer)
            installedView = nil
            pendingSourceID = nil
            state.cancel()
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            guard let captureView else {
                return false
            }

            let location = touch.location(in: captureView)
            // Although installed on the window, this recognizer only participates in touches that
            // start inside this container and on a currently registered source.
            guard captureView.bounds.contains(location), let sourceID = state.sourceID(at: location) else {
                pendingSourceID = nil
                return false
            }

            pendingSourceID = sourceID
            return true
        }

        @objc private func handleGesture(_ recognizer: UILongPressGestureRecognizer) {
            guard let captureView else {
                state.cancel()
                return
            }

            let location = recognizer.location(in: captureView)

            switch recognizer.state {
            case .began:
                // The activation delay has elapsed without exceeding the movement tolerance.
                guard let pendingSourceID, state.begin(sourceID: pendingSourceID, at: location) else {
                    state.cancel()
                    return
                }
            case .changed:
                state.drag(to: location)
            case .ended:
                // Only a normal end produces a drop operation.
                if let drop = state.finish(at: location) {
                    onDrop(drop)
                }
                pendingSourceID = nil
            case .cancelled, .failed:
                // Scrolling, system interruption, or an early release must never commit a drop.
                pendingSourceID = nil
                state.cancel()
            default:
                break
            }
        }
    }
}

private final class ShortcutDragCaptureUIView: UIView {
    var windowDidChange: ((UIWindow?) -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        windowDidChange?(window)
    }
}
#elseif canImport(AppKit)
/// AppKit counterpart of the UIKit bridge, using a continuous primary-button press recognizer.
private struct ShortcutDragGestureBridge: NSViewRepresentable {
    var state: ShortcutDragState
    var onDrop: (ShortcutDrop) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(state: state, onDrop: onDrop)
    }

    func makeNSView(context: Context) -> ShortcutDragCaptureNSView {
        let view = ShortcutDragCaptureNSView()
        view.windowDidChange = { [weak coordinator = context.coordinator] window in
            coordinator?.attach(to: window?.contentView)
        }
        context.coordinator.captureView = view
        return view
    }

    func updateNSView(_ nsView: ShortcutDragCaptureNSView, context: Context) {
        context.coordinator.state = state
        context.coordinator.onDrop = onDrop
        context.coordinator.attach(to: nsView.window?.contentView)
    }

    static func dismantleNSView(_ nsView: ShortcutDragCaptureNSView, coordinator: Coordinator) {
        coordinator.detach()
    }

    @MainActor
    final class Coordinator: NSObject, NSGestureRecognizerDelegate {
        var state: ShortcutDragState
        var onDrop: (ShortcutDrop) -> Void
        weak var captureView: NSView?

        private weak var installedView: NSView?

        /// Captured from the initial mouse event before the press recognizer begins.
        private var pendingSourceID: UUID?

        private lazy var recognizer: NSPressGestureRecognizer = {
            let recognizer = NSPressGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
            recognizer.minimumPressDuration = dragActivationDuration
            recognizer.allowableMovement = dragActivationMovement
            recognizer.buttonMask = 0x1
            recognizer.delegate = self
            return recognizer
        }()

        init(state: ShortcutDragState, onDrop: @escaping (ShortcutDrop) -> Void) {
            self.state = state
            self.onDrop = onDrop
        }

        func attach(to view: NSView?) {
            guard installedView !== view else {
                return
            }

            installedView?.removeGestureRecognizer(recognizer)
            installedView = view
            // The window content view is a reliable ancestor of both the SwiftUI content and the
            // transparent coordinate-reference view.
            view?.addGestureRecognizer(recognizer)
        }

        func detach() {
            installedView?.removeGestureRecognizer(recognizer)
            installedView = nil
            pendingSourceID = nil
            state.cancel()
        }

        func gestureRecognizer(
            _ gestureRecognizer: NSGestureRecognizer,
            shouldAttemptToRecognizeWith event: NSEvent
        ) -> Bool {
            guard let captureView, captureView.window === event.window else {
                return false
            }

            let location = captureView.convert(event.locationInWindow, from: nil)
            // Ignore events outside this container or outside all registered sources.
            guard captureView.bounds.contains(location), let sourceID = state.sourceID(at: location) else {
                pendingSourceID = nil
                return false
            }

            pendingSourceID = sourceID
            return true
        }

        @objc private func handleGesture(_ recognizer: NSPressGestureRecognizer) {
            guard let captureView else {
                state.cancel()
                return
            }

            let location = recognizer.location(in: captureView)

            switch recognizer.state {
            case .began:
                // The activation delay has elapsed without exceeding the movement tolerance.
                guard let pendingSourceID, state.begin(sourceID: pendingSourceID, at: location) else {
                    state.cancel()
                    return
                }
            case .changed:
                state.drag(to: location)
            case .ended:
                // Only a normal end produces a drop operation.
                if let drop = state.finish(at: location) {
                    onDrop(drop)
                }
                pendingSourceID = nil
            case .cancelled, .failed:
                // A failed press or system cancellation only clears transient state.
                pendingSourceID = nil
                state.cancel()
            default:
                break
            }
        }
    }
}

private final class ShortcutDragCaptureNSView: NSView {
    var windowDidChange: ((NSWindow?) -> Void)?

    override var isFlipped: Bool {
        // Match SwiftUI's top-left coordinate direction when converting mouse locations.
        true
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        // Never cover buttons or other SwiftUI interactions with the background bridge view.
        nil
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        windowDidChange?(window)
    }
}
#else
private struct ShortcutDragGestureBridge: View {
    var state: ShortcutDragState
    var onDrop: (ShortcutDrop) -> Void

    var body: some View {
        Color.clear
    }
}
#endif
