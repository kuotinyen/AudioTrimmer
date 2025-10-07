//
//  ClosedRange+Helpers.swift
//  AudioTrimmer
//
//  Created by Ting-Yen, Kuo on 2025/10/7.
//

import Foundation

extension ClosedRange where Bound == Double {
    /// Validates that the range is within 0.0~1.0 and has a minimum width
    func validated(minWidth: Double = 0.05) -> ClosedRange<Double> {
        let lower = lowerBound.clamped()
        var upper = upperBound.clamped()

        if upper - lower < minWidth {
            upper = min(1.0, lower + minWidth)
        }

        return lower...upper
    }
}
