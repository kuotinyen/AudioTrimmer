//
//  SettingsFeature.swift
//  AudioTrimmer
//
//  Created by Ting-Yen, Kuo on 2025/10/7.
//

import ComposableArchitecture
import Foundation

@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable {
        var totalLengthSeconds: Double = 150
        var keyTimesInput: String = "10, 35, 68"
        var musicTimelineSelectionLengthPercent: Double = 25
        var validationError: String? = nil
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case validateAndOpenTrimmer
        case delegate(Delegate)
        
        enum Delegate {
            case openTrimmer(TrimmerConfiguration)
        }
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .validateAndOpenTrimmer:
                state.validationError = validateSettings(
                    totalLengthSeconds: state.totalLengthSeconds,
                    keyTimesInput: state.keyTimesInput,
                    selectionLengthPercent: state.musicTimelineSelectionLengthPercent
                )
                
                // If validation passes, send delegate action
                if state.validationError == nil {
                    let config = TrimmerConfiguration(
                        totalLengthSeconds: state.totalLengthSeconds,
                        keyTimePercents: state.keyTimesInput.toPercents(),
                        musicTimelineSelectionLengthPercent: state.musicTimelineSelectionLengthPercent / 100.0
                    )
                    return .send(.delegate(.openTrimmer(config)))
                }
                return .none
            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - Private Helpers

private extension SettingsFeature {
    func validateSettings(
        totalLengthSeconds: Double,
        keyTimesInput: String,
        selectionLengthPercent: Double
    ) -> String? {
        // Validate total-length-seconds
        guard totalLengthSeconds > 0 else {
            return "Total length must be greater than 0."
        }
        
        // Validate keyTimes
        let keyTimes = keyTimesInput.toPercents()
        
        guard !keyTimes.isEmpty else {
            return "Key times must not be empty."
        }
        
        guard keyTimes.allSatisfy({ 0.0...100.0 ~= $0 }) else {
            return "All key times must be between 0.0 and 100.0."
        }
        
        for i in 1..<keyTimes.count where keyTimes[i] <= keyTimes[i - 1] {
            return "Key time at index \(i) must be greater than the key time at index \(i - 1)."
        }
        
        // Validate selection-length-percent
        guard selectionLengthPercent > 0, selectionLengthPercent <= 100 else {
            return "Selection length must be between 0.0 and 100.0."
        }
        
        return nil
    }
}

