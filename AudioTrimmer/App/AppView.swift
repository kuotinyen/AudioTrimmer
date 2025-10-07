//
//  AppView.swift
//  AudioTrimmer
//
//  Created by Ting-Yen, Kuo on 2025/10/7.
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        NavigationStack {
            SettingsView(
                store: store.scope(state: \.settings, action: \.settings)
            )
            .navigationDestination(item: $store.scope(state: \.trimmer, action: \.trimmer)) { trimmerStore in
                TrimmerView(store: trimmerStore)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
