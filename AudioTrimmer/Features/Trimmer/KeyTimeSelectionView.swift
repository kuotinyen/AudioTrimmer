//
//  KeyTimeSelectionView.swift
//  AudioTrimmer
//
//  Created by Ting-Yen, Kuo on 2025/10/7.
//

import SwiftUI

struct KeyTimeSelectionView: View {
    let keyTimes: [Double]
    let musicTimelineSelection: ClosedRange<Double>
    let current: Double
    let onKeyTimeTapped: (Double) -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("KeyTime Selection")
                .font(.headline)
            
            Text("Selection: \(musicTimelineSelection.lowerBound.toPercentString()) - \(musicTimelineSelection.upperBound.toPercentString())")
                .font(.body)
            
            Text("Current: \(current.toPercentString())")
                .font(.body)
                .foregroundStyle(.green)
            
            // Key Time Points Bar
            KeyTimePointsBar(
                keyTimes: keyTimes,
                musicTimelineSelection: musicTimelineSelection,
                onKeyTimeTapped: onKeyTimeTapped
            )
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemGray6).opacity(0.3))
    }
}

// MARK: - KeyTimePointsBar

extension KeyTimeSelectionView {
    struct KeyTimePointsBar: View {
        let keyTimes: [Double]
        let musicTimelineSelection: ClosedRange<Double>
        let onKeyTimeTapped: (Double) -> Void

        var body: some View {
            GeometryReader { geometry in
                let barWidth = geometry.size.width
                let barHeight = geometry.size.height
                
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: barWidth, height: barHeight)
                    
                    // Yellow bar for music timeline selection
                    let selectionStart = musicTimelineSelection.lowerBound
                    let selectionEnd = musicTimelineSelection.upperBound
                    let selectionWidth = (selectionEnd - selectionStart) * barWidth
                    let selectionOffset = selectionStart * barWidth
                    
                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .fill(Color.yellow)
                        .frame(width: selectionWidth, height: barHeight)
                        .offset(x: selectionOffset)
                    
                    // Red dots for key time points
                    ForEach(keyTimes, id: \.self) { keyTime in
                        let dotOffset = keyTime * barWidth
                        let dotLength: CGFloat = barHeight + 4

                        Circle()
                            .fill(Color.red)
                            .frame(width: dotLength, height: dotLength)
                            .offset(x: dotOffset - 5)  // Center the dot
                            .onTapGesture {
                                onKeyTimeTapped(keyTime)
                            }
                    }
                }
            }
            .frame(height: 12)
        }
    }
}

// MARK: - Preview

#Preview {
    KeyTimeSelectionView(
        keyTimes: [0.1, 0.35, 0.68],
        musicTimelineSelection: 0.42...0.46,
        current: 0.408,
        onKeyTimeTapped: { _ in }
    )
    .background(Color.black)
}
