//
//  TrimmerConfiguration.swift
//  AudioTrimmer
//
//  Created by Ting-Yen, Kuo on 2025/10/5.
//

struct TrimmerConfiguration: Equatable {
    var totalLengthSeconds: Double
    var keyTimePercents: [Double]  // 0.0 ~ 1.0
    var musicTimelineSelectionLengthPercent: Double  // 0.0 ~ 1.0

    init(
        totalLengthSeconds: Double = 30,
        keyTimePercents: [Double] = [0.1, 0.35, 0.68],
        musicTimelineSelectionLengthPercent: Double = 0.25,  // Default: 25% of total
    ) {
        self.totalLengthSeconds = totalLengthSeconds
        self.keyTimePercents = keyTimePercents.sorted()
        self.musicTimelineSelectionLengthPercent = musicTimelineSelectionLengthPercent
    }
}
