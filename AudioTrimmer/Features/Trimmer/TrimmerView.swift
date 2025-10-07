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
        ScrollView  {
            VStack {
                // KeyTime
                KeyTimeSelectionView(
                    keyTimes: store.keyTimes,
                    musicTimelineSelection: store.musicTimelineSelection,
                    current: store.playhead,
                    onKeyTimeTapped: { percent in
                        store.send(.keyTimeTapped(percent))
                    }
                )
                .background(Color(.systemGray6))
                
                Divider()
                
                // Timeline
                TimelineView(
                    totalLengthSeconds: store.config.totalLengthSeconds,
                    musicTimelineSelection: store.musicTimelineSelection,
                    playhead: store.playhead,
                    playState: store.playState,
                    playedProgress: store.playedProgress,
                    onMusicTimelineSelectionDragged: { offset in
                        store.send(.musicTimelineSelectionDragged(offset: offset))
                    },
                    onDragStarted: {
                        store.send(.dragStarted)
                    },
                    onDragEnded: {
                        store.send(.dragEnded)
                    },
                    onPlayTapped: {
                        store.send(.playTapped)
                    },
                    onPauseTapped: {
                        store.send(.pauseTapped)
                    },
                    onResetTapped: {
                        store.send(.resetTapped)
                    }
                )
            }
        }
    }
}
