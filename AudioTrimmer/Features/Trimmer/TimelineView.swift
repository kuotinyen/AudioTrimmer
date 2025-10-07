//
//  TimelineView.swift
//  AudioTrimmer
//
//  Created by Ting-Yen, Kuo on 2025/10/7.
//

import SwiftUI

struct TimelineView: View {
    let totalLengthSeconds: Double
    let musicTimelineSelection: ClosedRange<Double>
    let playhead: Double
    let playState: PlayState
    let playedProgress: Double
    
    let onMusicTimelineSelectionDragged: (Double) -> Void
    let onDragStarted: () -> Void
    let onDragEnded: () -> Void
    let onPlayTapped: () -> Void
    let onPauseTapped: () -> Void
    let onResetTapped: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            headerInfoView

            TimelineFixedViewPortView(
                musicTimelineSelection: musicTimelineSelection,
                playedProgress: playedProgress,
                onMusicTimelineSelectionDragged: onMusicTimelineSelectionDragged,
                onDragStarted: onDragStarted,
                onDragEnded: onDragEnded
            )
            .frame(height: 120)

            HStack(spacing: 20) {
                playButton
                resetButton
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Subviews

private extension TimelineView {
    var headerInfoView: some View {
        VStack(spacing: 8) {
            Text("Music Timeline")
                .font(.headline)

            Text("Selected: \((musicTimelineSelection.lowerBound * totalLengthSeconds).toTimeString()) → \((musicTimelineSelection.upperBound * totalLengthSeconds).toTimeString())")
                .font(.body)

            Text("Current: \((playhead * totalLengthSeconds).toTimeString())")
                .font(.body)
                .foregroundStyle(.green)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    var playButton: some View {
        Button(action: {
            if playState == .playing {
                onPauseTapped()
            } else {
                onPlayTapped()
            }
        }) {
            Label(
                playState == .playing ? "Pause" : "Play",
                systemImage: playState == .playing ? "pause.fill" : "play.fill"
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }
    
    var resetButton: some View {
        Button(action: onResetTapped) {
            Label("Reset", systemImage: "arrow.counterclockwise")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
}

// MARK: - Preview

#Preview {
    TimelineView(
        totalLengthSeconds: 120,
        musicTimelineSelection: 0.3...0.55,  // 25% width
        playhead: 0.35,
        playState: .idle,
        playedProgress: 0.0,
        onMusicTimelineSelectionDragged: { _ in },
        onDragStarted: {},
        onDragEnded: {},
        onPlayTapped: {},
        onPauseTapped: {},
        onResetTapped: {}
    )
    .padding()
    .background(Color.black)
}
