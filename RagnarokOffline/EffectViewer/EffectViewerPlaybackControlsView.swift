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
                EffectViewerPlaybackRateButton(renderer: renderer)

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

    var body: some View {
        HStack(spacing: 10) {
            Text(formattedReadout(forTick: currentTick))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(width: 80, alignment: .leading)

            Slider(
                value: Binding(
                    get: {
                        sliderValue
                    },
                    set: { newValue in
                        renderer?.seek(toTick: Int(newValue.rounded()))
                    }
                ),
                in: Double(minTick)...Double(sliderUpperBound),
                step: 1
            ) { editing in
                if editing {
                    renderer?.pause()
                }
            }
            .disabled(renderer == nil || maxTick <= minTick)

            Text(totalReadout)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(width: 80, alignment: .trailing)
        }
    }

    private var currentTick: Int {
        renderer?.currentTick ?? 0
    }

    private var minTick: Int {
        renderer?.minTick ?? 0
    }

    private var maxTick: Int {
        renderer?.maxTick ?? 0
    }

    private var sliderUpperBound: Int {
        max(minTick + 1, maxTick)
    }

    private var sliderValue: Double {
        Double(min(max(currentTick, minTick), sliderUpperBound))
    }

    private var totalReadout: String {
        guard let renderer, renderer.totalTicks != nil else {
            return "—"
        }
        return formattedReadout(forTick: renderer.maxTick)
    }

    private func formattedReadout(forTick tick: Int) -> String {
        let seconds = Double(tick) / EffectManager.tickRate
        return String(format: "%.2fs · T%d", seconds, tick)
    }
}

private struct EffectViewerPlaybackRateButton: View {
    var renderer: EffectViewerEffectRenderer?

    var body: some View {
        Button {
            renderer?.cyclePlaybackRate()
        } label: {
            Text(playbackRate.label)
                .font(.subheadline.monospacedDigit().weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(width: 60, height: 28)
                .background(.primary.opacity(0.08), in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .contextMenu {
            ForEach(EffectViewerPlaybackRate.allCases.reversed()) { rate in
                Button {
                    renderer?.playbackRate = rate
                } label: {
                    if rate == playbackRate {
                        Label(rate.label, systemImage: "checkmark")
                    } else {
                        Text(rate.label)
                    }
                }
            }
        }
        .disabled(renderer == nil)
    }

    private var playbackRate: EffectViewerPlaybackRate {
        renderer?.playbackRate ?? .normal
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
                    .frame(width: 32, height: 32)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(renderer?.canStepBackward != true)

            Button {
                renderer?.togglePlayPause()
            } label: {
                Image(systemName: primaryActionIcon)
                    .font(.title2.weight(.semibold))
                    .frame(width: 32, height: 32)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(renderer == nil)

            Button {
                renderer?.stepForwardTick()
            } label: {
                Image(systemName: "forward.frame.fill")
                    .font(.body.weight(.medium))
                    .frame(width: 32, height: 32)
                    .contentShape(Circle())
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
                .frame(width: 60, height: 28)
                .background(
                    isLooping ? Color.accentColor.opacity(0.2) : Color.clear,
                    in: Capsule()
                )
                .contentShape(Capsule())
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
