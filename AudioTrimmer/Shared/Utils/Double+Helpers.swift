//
//  Double+Helpers.swift
//  AudioTrimmer
//
//  Created by Ting-Yen, Kuo on 2025/10/7.
//

import Foundation

extension Double {
    /// Clamps the value between 0.0 and 1.0
    func clamped() -> Double {
        max(0.0, min(1.0, self))
    }

    /// Converts a percentage (0.0~1.0) to display string
    func toPercentString() -> String {
        String(format: "%.1f%%", self * 100)
    }
}
