# AudioTrimmer - iOS Audio Trimmer Homework

A SwiftUI-based audio trimmer application built with The Composable Architecture (TCA), featuring intuitive timeline manipulation and keyframe navigation.

## 📱 Demo
| Settings | Trimmer |
| ----------- | ----------- |
| ![CleanShot 2025-10-08 at 02 08 10](https://github.com/user-attachments/assets/2af63722-22ae-4c9e-be06-23172ea47654) | ![CleanShot 2025-10-08 at 02 08 45](https://github.com/user-attachments/assets/d9054f02-3ab4-49be-8438-ecf0a4f6c570) | 

## Features

### Settings Configuration
- Configurable total track length (seconds)
- Multiple keyTime points as percentages (0-100%)
- Adjustable timeline selection length (percentage of total)
- Input validation with real-time feedback

### Audio Trimmer
- Play/Pause selected audio segment
- Reset playback to start
- Drag to adjust selection window
- Tap keyTime markers to jump to specific positions
- Real-time progress visualization
- Waveform visualization with fixed viewport


## Architecture Overview

This project follows **The Composable Architecture (TCA)** principles for predictable state management and testable code.

### Architecture Diagram
```mermaid
graph TB
    subgraph App_Layer [App Layer]
        AppFeature[AppFeature]
        AppView[AppView]
    end

    subgraph Settings_Module [Settings Module]
        SettingsFeature[SettingsFeature]
        SettingsView[SettingsView]
    end

    subgraph Trimmer_Module [Trimmer Module]
        TrimmerFeature[TrimmerFeature]
        TrimmerView[TrimmerView]

        subgraph Trimmer_Subviews [Trimmer Subviews]
            KeyTimeView[KeyTimeSelectionView]
            TimelineView[TimelineView]
            FixedViewport[TimelineFixedViewportView]
        end
    end

    AppFeature --> SettingsFeature
    AppFeature --> TrimmerFeature
    AppView --> SettingsView
    AppView --> TrimmerView

    SettingsFeature -.-> AppFeature

    TrimmerView --> KeyTimeView
    TrimmerView --> TimelineView
    TimelineView --> FixedViewport
```


## TCA Features Breakdown

### AppFeature
**Responsibility**: Root coordinator managing navigation and feature integration

```swift
State:
  - settings: SettingsFeature.State
  - trimmer: TrimmerFeature.State? (@Presents)

Actions:
  - settings(SettingsFeature.Action)
  - trimmer(PresentationAction<TrimmerFeature.Action>)

Key Logic:
  - Handles delegate actions from SettingsFeature
  - Presents TrimmerFeature with validated configuration
```

### SettingsFeature
**Responsibility**: Configuration and validation

```swift
State:
  - totalLengthSeconds: Double
  - musicTimelineSelectionLengthPercent: Double
  - keyTimePercents: [Double]

Actions:
  - binding (BindingAction)
  - validateAndOpenTrimmer
  - delegate(Delegate)

Key Logic:
  - Real-time input validation
  - Sends .openTrimmer delegate action to parent
```

### TrimmerFeature
**Responsibility**: Audio trimming logic and playback simulation

```swift
State:
  - config: TrimmerConfiguration
  - musicTimelineSelection: ClosedRange<Double>
  - playhead: Double
  - playState: PlayState (.idle/.playing/.paused/.completed)
  - playedProgress: Double

Actions:
  - playTapped / pauseTapped / resetTapped
  - keyTimeTapped(Double)
  - musicTimelineSelectionDragged(offset: Double)
  - dragStarted / dragEnded
  - tick (100ms interval)

Key Logic:
  - Playback simulation with timer
  - Selection window drag with clamping
  - Auto-resume after drag delay (1 sec)
  - KeyTime navigation with boundary checking
```

## View Hierarchy

```mermaid
graph LR
    AppView --> SettingsView
    AppView --> TrimmerView

    TrimmerView --> KeyTimeSelectionView
    TrimmerView --> TimelineView

    TimelineView --> HeaderInfo[Header Info<br/>Selected Range & Playhead]
    TimelineView --> TimelineFixedViewPortView
    TimelineView --> Controls[Play/Pause & Reset Buttons]

    TimelineFixedViewPortView --> Waveform[FullWaveformBackground<br/>Scrollable Waveform Icons]
    TimelineFixedViewPortView --> Selection[InnerMusicTimelineSelection<br/>Selection Box with Progress]

    KeyTimeSelectionView --> KeyBar[KeyTimePointsBar<br/>Timeline with Red Markers]

    style TrimmerView fill:#fff4e1
    style TimelineFixedViewPortView fill:#ffe1e1
    style KeyTimeSelectionView fill:#e1ffe1
```

## User Flow

### Complete User Journey

```mermaid
sequenceDiagram
    actor User
    participant Settings as SettingsView
    participant SF as SettingsFeature
    participant AF as AppFeature
    participant Trimmer as TrimmerView
    participant TF as TrimmerFeature

    User->>Settings: 1. Launch App
    Note over Settings: Enter Settings Screen

    User->>Settings: 2. Input Configuration
    Settings->>SF: Binding updates
    SF->>SF: Validate inputs

    User->>Settings: 3. Tap "Open Trimmer"
    Settings->>SF: .validateAndOpenTrimmer
    SF->>SF: Final validation
    SF->>AF: .delegate(.openTrimmer(config))
    AF->>AF: Create TrimmerFeature.State
    AF->>Trimmer: Present sheet

    Note over Trimmer: Enter Trimmer Screen

    alt Option A: Tap KeyTime Marker
        User->>Trimmer: 4a. Tap red keyTime dot
        Trimmer->>TF: .keyTimeTapped(percent)
        TF->>TF: Move selection to keyTime
        TF->>Trimmer: Update UI
    end

    alt Option B: Drag Selection
        User->>Trimmer: 4b. Drag selection box
        Trimmer->>TF: .dragStarted
        TF->>TF: Pause if playing
        User->>Trimmer: Continue dragging
        Trimmer->>TF: .musicTimelineSelectionDragged(offset)
        TF->>TF: Update selection position
        User->>Trimmer: Release drag
        Trimmer->>TF: .dragEnded
        TF->>TF: Wait 1 sec
        TF->>TF: .resumeAfterDrag (if was playing)
    end

    User->>Trimmer: 5. Tap Play
    Trimmer->>TF: .playTapped
    TF->>TF: Start timer (100ms interval)
    loop Every 100ms
        TF->>TF: .tick
        TF->>TF: Update playhead & progress
        TF->>Trimmer: Refresh UI
    end

    alt Playback Complete
        TF->>TF: Reach selection end
        TF->>TF: Set state to .completed
        TF->>TF: Cancel timer
    end

    alt User Pause
        User->>Trimmer: 6. Tap Pause
        Trimmer->>TF: .pauseTapped
        TF->>TF: Cancel timer
    end

    User->>Trimmer: 7. Tap Reset
    Trimmer->>TF: .resetTapped
    TF->>TF: Reset to idle state
    TF->>Trimmer: Update UI
```

