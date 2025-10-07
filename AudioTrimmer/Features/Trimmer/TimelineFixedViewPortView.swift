//
//  TimelineFixedViewPortView.swift
//  AudioTrimmer
//
//  Created by Ting-Yen, Kuo on 2025/10/7.
//

import SwiftUI

struct TimelineFixedViewPortView: View {
    let musicTimelineSelection: ClosedRange<Double>
    let playedProgress: Double
    let onMusicTimelineSelectionDragged: (Double) -> Void
    let onDragStarted: () -> Void
    let onDragEnded: () -> Void

    @State private var lastDragValue: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let viewportWidth = geometry.size.width
            let selectionSize = musicTimelineSelection.upperBound - musicTimelineSelection.lowerBound
            let windowWidth = selectionSize * viewportWidth
            let fullWaveformWidth = windowWidth / selectionSize
            let selectionLeftEdge = viewportWidth / 2 - windowWidth / 2
            let waveformOffset = selectionLeftEdge - musicTimelineSelection.lowerBound * fullWaveformWidth

            ZStack {
                FullWaveformBackground(
                    width: fullWaveformWidth,
                    height: geometry.size.height,
                    offset: waveformOffset
                )

                InnerMusicTimelineSelection(
                    musicTimelineSelection: musicTimelineSelection,
                    playedProgress: playedProgress,
                    viewportWidth: viewportWidth
                )
                .allowsHitTesting(false)
            }
            .clipped()
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if lastDragValue == 0 {
                            onDragStarted()
                        }
                        let delta = value.translation.width - lastDragValue
                        let offset = -delta / fullWaveformWidth  // Negative because we're moving the content
                        onMusicTimelineSelectionDragged(offset)
                        lastDragValue = value.translation.width
                    }
                    .onEnded { _ in
                        lastDragValue = 0
                        onDragEnded()
                    }
            )
        }
    }
}

// MARK: - FullWaveformBackground

private extension TimelineFixedViewPortView {
    struct FullWaveformBackground: View {
        let width: CGFloat
        let height: CGFloat
        let offset: CGFloat

        var body: some View {
            let symbolWidth: CGFloat = 50
            let symbolCount = Int(ceil(width / symbolWidth))

            HStack(spacing: 5) {
                ForEach(0..<symbolCount, id: \.self) { index in
                    Image(systemName: "waveform")
                        .resizable()
                        .scaledToFit()
                        .frame(width: symbolWidth, height: height)
                        .foregroundColor(.white)
                }
            }
            .frame(width: width, height: height, alignment: .leading)
            .clipped()
            .offset(x: offset)
            .background(Color.black.opacity(0.1))
        }
    }
}

// MARK: - InnerMusicTimelineSelection

private extension TimelineFixedViewPortView {
    struct InnerMusicTimelineSelection: View {
        let musicTimelineSelection: ClosedRange<Double>
        let playedProgress: Double
        let viewportWidth: CGFloat

        var body: some View {
            GeometryReader { geometry in
                let selectionSize = musicTimelineSelection.upperBound - musicTimelineSelection.lowerBound
                let windowWidth = selectionSize * viewportWidth
                let centerX = viewportWidth / 2

                let borderLineWidth: CGFloat = 4
                let borderInset: CGFloat = borderLineWidth / 2
                let outerCornerRadius: CGFloat = 12
                let innerCornerRadius: CGFloat = outerCornerRadius - borderInset
                
                let innerWidth = windowWidth - borderInset * 2
                let innerHeight = geometry.size.height / 2 - borderInset * 2
                let actualPlayedWidth = playedProgress * innerWidth

                return ZStack(alignment: .center) {
                    // Border
                    RoundedRectangle(cornerRadius: outerCornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [.orange, .pink, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: borderLineWidth
                        )
                        .frame(width: windowWidth, height: geometry.size.height / 2)
                        .position(x: centerX, y: geometry.size.height / 2)

                    // Container for background and progress fill
                    ZStack(alignment: .leading) {
                        // Orange default
                        Color.orange.opacity(0.2)
                            .frame(width: innerWidth, height: innerHeight)
                        
                        // Green fill
                        if playedProgress > 0 {
                            Color.green.opacity(0.4)
                                .frame(width: actualPlayedWidth, height: innerHeight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(width: innerWidth, height: innerHeight)
                    .clipShape(RoundedRectangle(cornerRadius: innerCornerRadius))
                    .position(x: centerX, y: geometry.size.height / 2)
                }
            }
        }
    }
}
