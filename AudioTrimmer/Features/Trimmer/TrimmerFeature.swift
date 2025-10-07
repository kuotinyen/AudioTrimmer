//
//  TrimmerFeature.swift
//  AudioTrimmer
//
//  Created by Ting-Yen, Kuo on 2025/10/7.
//

import ComposableArchitecture
import Foundation

@Reducer
struct TrimmerFeature {
    @ObservableState
    struct State: Equatable {
        var config: TrimmerConfiguration
        var musicTimelineSelection: ClosedRange<Double>
        var playhead: Double = 0.0
        var playState: PlayState = .idle
        var playedProgress: Double = 0.0
        var wasPlayingBeforeDrag: Bool = false

        init(config: TrimmerConfiguration) {
            self.config = config

            let selectionSize = config.musicTimelineSelectionLengthPercent.clamped()
            self.musicTimelineSelection = (0.0...selectionSize).validated()
        }
        
        var keyTimes: [Double] {
            config.keyTimePercents
        }

        var selectionSize: Double {
            musicTimelineSelection.upperBound - musicTimelineSelection.lowerBound
        }

        var relativePlayhead: Double {
            playhead - musicTimelineSelection.lowerBound
        }
    }

    enum Action: Equatable {
        case playTapped
        case pauseTapped
        case resetTapped
        case keyTimeTapped(Double)
        case musicTimelineSelectionDragged(offset: Double)
        case dragStarted
        case dragEnded
        case resumeAfterDrag
        case tick
    }

    @Dependency(\.continuousClock) var clock

    private enum CancelID { case timer, resumeDelay }
    private static let tickInterval: Duration = .milliseconds(100)
    private static let resumeDelay: Duration = .seconds(1)

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .playTapped:
                return startPlayback(&state)

            case .pauseTapped:
                return pausePlayback(&state)

            case .resetTapped:
                return resetPlayback(&state)

            case .keyTimeTapped(let percent):
                return handleKeyTimeTapped(&state, percent: percent)

            case .musicTimelineSelectionDragged(let offset):
                return handleSelectionDragged(&state, offset: offset)

            case .dragStarted:
                return handleDragStarted(&state)

            case .dragEnded:
                return handleDragEnded(&state)

            case .resumeAfterDrag:
                return resumePlaybackAfterDrag(&state)

            case .tick:
                return handleTick(&state)
            }
        }
    }
}

// MARK: - Private helpers

private extension TrimmerFeature {
    // MARK: Playback Helpers

    func startPlayback(_ state: inout State) -> Effect<Action> {
        state.playState = .playing
        state.playhead = state.musicTimelineSelection.lowerBound
        state.playedProgress = 0.0

        return startPlaybackTimer()
    }

    func pausePlayback(_ state: inout State) -> Effect<Action> {
        state.playState = .paused
        state.wasPlayingBeforeDrag = false
        return cancelAllTimers()
    }

    func resetPlayback(_ state: inout State) -> Effect<Action> {
        state.playState = .idle
        state.playhead = state.musicTimelineSelection.lowerBound
        state.playedProgress = 0.0
        state.wasPlayingBeforeDrag = false
        return cancelAllTimers()
    }

    func startPlaybackTimer() -> Effect<Action> {
        .run { send in
            for await _ in self.clock.timer(interval: Self.tickInterval) {
                await send(.tick)
            }
        }
        .cancellable(id: CancelID.timer)
    }

    func cancelAllTimers() -> Effect<Action> {
        .merge(
            .cancel(id: CancelID.timer),
            .cancel(id: CancelID.resumeDelay)
        )
    }
    
    // MARK: Key Time Helpers

    private func handleKeyTimeTapped(_ state: inout State, percent: Double) -> Effect<Action> {
        var newStart = percent
        let maxStart = 1.0 - state.selectionSize
        newStart = min(max(newStart, 0.0), maxStart)
        state.musicTimelineSelection = (newStart...(newStart + state.selectionSize)).validated()
        state.playhead = state.musicTimelineSelection.lowerBound

        if state.playState == .playing {
            state.playState = .idle
            return .cancel(id: CancelID.timer)
        }

        return .none
    }
    
    // MARK: Drag Helpers
    
    func handleSelectionDragged(_ state: inout State, offset: Double) -> Effect<Action> {
        let newStart = state.musicTimelineSelection.lowerBound + offset
        let clampedStart = min(max(newStart, 0.0), 1.0 - state.selectionSize)
        state.musicTimelineSelection = (clampedStart...(clampedStart + state.selectionSize)).validated()
        state.playhead = state.musicTimelineSelection.lowerBound

        return .none
    }

    func handleDragStarted(_ state: inout State) -> Effect<Action> {
        state.playedProgress = 0.0

        if state.playState == .playing {
            state.wasPlayingBeforeDrag = true
            return .cancel(id: CancelID.timer)
        }

        state.wasPlayingBeforeDrag = false
        return .none
    }

    func handleDragEnded(_ state: inout State) -> Effect<Action> {
        guard state.wasPlayingBeforeDrag else {
            return .none
        }

        // delay and resume playing
        return .run { send in
            try await self.clock.sleep(for: Self.resumeDelay)
            await send(.resumeAfterDrag)
        }
        .cancellable(id: CancelID.resumeDelay)
    }

    func resumePlaybackAfterDrag(_ state: inout State) -> Effect<Action> {
        guard state.wasPlayingBeforeDrag else {
            return .none
        }

        state.playState = .playing
        state.playhead = state.musicTimelineSelection.lowerBound
        state.playedProgress = 0.0
        state.wasPlayingBeforeDrag = false

        return startPlaybackTimer()
    }
    
    // MARK: Tick Helper

    func handleTick(_ state: inout State) -> Effect<Action> {
        guard state.playState == .playing else {
            return .cancel(id: CancelID.timer)
        }

        let increment = 0.1 / state.config.totalLengthSeconds
        state.playhead += increment

        state.playedProgress = min(max(state.relativePlayhead / state.selectionSize, 0.0), 1.0)

        if state.playhead >= state.musicTimelineSelection.upperBound {
            state.playhead = state.musicTimelineSelection.upperBound
            state.playedProgress = 1.0
            state.playState = .completed
            return .cancel(id: CancelID.timer)
        }

        return .none
    }
}
