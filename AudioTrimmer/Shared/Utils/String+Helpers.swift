//
//  String+Helpers.swift
//  AudioTrimmer
//
//  Created by Ting-Yen, Kuo on 2025/10/7.
//

import Foundation

extension String {
    func toPercents() -> [Double] {
        self
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
            .map { ($0 / 100.0).clamped() }
            .sorted()
    }
}
