//
//  EffectViewerPlaybackControlsView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/11/26.
//

import RagnarokEffects
import SwiftUI

struct EffectViewerPlaybackControlsView: View {
    var renderer: EffectViewerEffectRenderer?

    var body: some View {
        VStack(spacing: 10) {
            EffectViewerProgressRow(renderer: renderer)

            HStack(spacing: 16) {
                EffectViewerPlaybackRateMenu(renderer: renderer)

                Spacer()

                EffectViewerTransportControls(renderer: renderer)

                Spacer()

                EffectViewerLoopButton(renderer: renderer)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: 460)
        .adaptivePlaybackBarBackground()
    }
}

private struct EffectViewerProgressRow: View {
    var renderer: EffectViewerEffectRenderer?

    @State private var isScrubbing = false
    @State private var scrubTick: Double = 0

    private var currentTick: Int {
        renderer?.currentTick ?? 0
    }

    private var minTick: Int {
        renderer?.minTick ?? 0
    }

    private var maxTick: Int {
        renderer?.maxTick ?? 0
    }

    private var displayedTick: Int {
        isScrubbing ? Int(scrubTick.rounded()) : currentTick
    }

    private var sliderUpperBound: Double {
        Double(max(minTick + 1, maxTick))
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(formattedReadout(forTick: displayedTick))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(minWidth: 74, alignment: .leading)

            Slider(
                value: Binding(
                    get: {
                        isScrubbing ? scrubTick : Double(currentTick)
                    },
                    set: { newValue in
                        scrubTick = newValue
                        renderer?.seek(toTick: Int(newValue.rounded()))
                    }
                ),
                in: Double(minTick)...sliderUpperBound,
                step: 1
            ) { editing in
                isScrubbing = editing
                if editing {
                    scrubTick = Double(currentTick)
                    renderer?.pause()
                }
            }
            .disabled(renderer == nil || maxTick <= minTick)

            Text(totalReadout)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(minWidth: 74, alignment: .trailing)
        }
        .onChange(of: currentTick) { _, newTick in
            if !isScrubbing {
                scrubTick = Double(newTick)
            }
        }
        .onAppear {
            scrubTick = Double(currentTick)
        }
    }

    private var totalReadout: String {
        guard let totalTicks = renderer?.totalTicks else {
            return "—"
        }
        return formattedReadout(forTick: totalTicks)
    }

    private func formattedReadout(forTick tick: Int) -> String {
        let seconds = Double(tick) / EffectManager.tickRate
        return String(format: "%.2fs · T%d", seconds, tick)
    }
}

private struct EffectViewerPlaybackRateMenu: View {
    var renderer: EffectViewerEffectRenderer?

    private var playbackRate: EffectViewerPlaybackRate {
        renderer?.playbackRate ?? .normal
    }

    var body: some View {
        Menu {
            Picker(
                String(),
                selection: Binding(
                    get: {
                        renderer?.playbackRate ?? .normal
                    },
                    set: { newRate in
                        renderer?.playbackRate = newRate
                    }
                )
            ) {
                ForEach(EffectViewerPlaybackRate.allCases) { rate in
                    Text(rate.label)
                        .tag(rate)
                }
            }
            .labelsHidden()
        } label: {
            Text(playbackRate.label)
                .font(.subheadline.monospacedDigit().weight(.medium))
                .foregroundStyle(.primary)
                .frame(minWidth: 46)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(.primary.opacity(0.08), in: Capsule())
        }
        .disabled(renderer == nil)
    }
}

private struct EffectViewerTransportControls: View {
    var renderer: EffectViewerEffectRenderer?

    private var primaryActionIcon: String {
        guard let renderer else {
            return "play.fill"
        }
        if renderer.isPlaying {
            return "pause.fill"
        } else if renderer.isCompleted {
            return "arrow.clockwise"
        } else {
            return "play.fill"
        }
    }

    var body: some View {
        HStack(spacing: 18) {
            Button {
                renderer?.stepBackwardTick()
            } label: {
                Image(systemName: "backward.frame.fill")
                    .font(.body.weight(.medium))
            }
            .buttonStyle(.plain)
            .disabled(renderer?.canStepBackward != true)

            Button {
                renderer?.togglePlayPause()
            } label: {
                Image(systemName: primaryActionIcon)
                    .font(.title2.weight(.semibold))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .disabled(renderer == nil)

            Button {
                renderer?.stepForwardTick()
            } label: {
                Image(systemName: "forward.frame.fill")
                    .font(.body.weight(.medium))
            }
            .buttonStyle(.plain)
            .disabled(renderer?.canStepForward != true)
        }
    }
}

private struct EffectViewerLoopButton: View {
    var renderer: EffectViewerEffectRenderer?

    private var isLooping: Bool {
        renderer?.isLooping ?? true
    }

    var body: some View {
        Button {
            renderer?.toggleLooping()
        } label: {
            Image(systemName: "repeat")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isLooping ? Color.accentColor : Color.secondary)
                .frame(width: 34, height: 28)
                .background(
                    isLooping ? Color.accentColor.opacity(0.2) : Color.clear,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .disabled(renderer == nil)
    }
}

private extension View {
    @ViewBuilder
    func adaptivePlaybackBarBackground() -> some View {
        #if os(visionOS)
        self.background(.ultraThinMaterial, in: .rect(cornerRadius: 20))
        #else
        if #available(iOS 26.0, macOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: 20))
        } else {
            self.background(.ultraThinMaterial, in: .rect(cornerRadius: 20))
        }
        #endif
    }
}

#Preview {
    EffectViewerPlaybackControlsView()
}
