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

        init(config: TrimmerConfiguration) {
            self.config = config
        }
    }

    enum Action {
        // TODO: Add actions as needed
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            }
        }
    }
}
