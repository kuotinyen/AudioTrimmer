//
//  TrimmerView.swift
//  AudioTrimmer
//
//  Created by Ting-Yen, Kuo on 2025/10/7.
//

import ComposableArchitecture
import SwiftUI

struct TrimmerView: View {
    @Bindable var store: StoreOf<TrimmerFeature>
    
    var body: some View {
        #warning("dummy view")
        VStack {
            Text(String(store.config.totalLengthSeconds))
            Text(store.config.keyTimePercents.map(\.description).joined(separator: ", "))
            Text(String(store.config.musicTimelineSelectionLengthPercent))
        }
    }
}
