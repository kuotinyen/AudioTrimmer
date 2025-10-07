//
//  SettingsView.swift
//  AudioTrimmer
//
//  Created by Ting-Yen, Kuo on 2025/10/7.
//

import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    totalTrackView
                } header: {
                    Text("Track Configuration")
                }

                Section {
                    keyTimeView
                } header: {
                    Text("Key Times")
                }

                Section {
                    musicTimelineView
                } header: {
                    Text("Selection Configuration")
                }

                if let error = store.validationError {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.callout)
                    }
                }

                Section {
                    openTrimmerButton
                        .buttonStyle(.borderedProminent)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Audio Trimmer Settings")
        }
    }
}

// MARK: - Subviews

private extension SettingsView {
    var totalTrackView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Track Length")
                .font(.headline)

            HStack {
                TextField("Seconds", value: $store.totalLengthSeconds, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)

                Text("sec")
                    .foregroundStyle(.secondary)
            }

            Text("\(store.totalLengthSeconds, specifier: "%.1f") seconds")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    var keyTimeView: some View {
        Group {
            VStack(alignment: .leading, spacing: 8) {
                Text("Key Time Points")
                    .font(.headline)
                
                TextField("e.g., 10, 35, 68", text: $store.keyTimesInput)
                    .textFieldStyle(.roundedBorder)
                
                Text("Enter percentages separated by commas")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Preview parsed key times
            let keyTimes = store.keyTimesInput.toPercents()
            if !keyTimes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Parsed Key Times:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(keyTimes, id: \.self) { percent in
                                Text(percent.toPercentString())
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundStyle(.blue)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
        }
    }
    
    var musicTimelineView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Music Timeline Selection Length")
                .font(.headline)

            HStack {
                TextField("Percent", value: $store.musicTimelineSelectionLengthPercent, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)

                Text("%")
                    .foregroundStyle(.secondary)
            }

            Slider(value: $store.musicTimelineSelectionLengthPercent, in: 5...100, step: 5)

            Text("\(store.musicTimelineSelectionLengthPercent, specifier: "%.0f")% of total length")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    var openTrimmerButton: some View {
        Button(action: {
            store.send(.validateAndOpenTrimmer)
        }) {
            HStack {
                Spacer()
                Text("Open Trimmer")
                    .font(.headline)
                Spacer()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView(
        store: Store(initialState: SettingsFeature.State()) {
            SettingsFeature()
        }
    )
}
