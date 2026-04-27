//
//  SoundManager.swift
//  Mako
//
//  Manages UI sound effects for user interactions
//

import AVFoundation
import Foundation
import Observation
import SwiftUI

// MARK: - Environment Key

private struct SoundManagerKey: EnvironmentKey {
    static let defaultValue: SoundManager? = nil
}

extension EnvironmentValues {
    var soundManager: SoundManager? {
        get { self[SoundManagerKey.self] }
        set { self[SoundManagerKey.self] = newValue }
    }
}

// MARK: - SoundManager

@MainActor
@Observable
final class SoundManager {
    private var deviceClickPlayer: AVAudioPlayer?
    private var detailClickPlayer: AVAudioPlayer?

    init() {
        loadSounds()
    }

    // MARK: - Public Methods

    func playDeviceClick() {
        deviceClickPlayer?.currentTime = 0
        deviceClickPlayer?.play()
    }

    func playDetailClick() {
        detailClickPlayer?.currentTime = 0
        detailClickPlayer?.play()
    }

    // MARK: - Private Methods

    private func loadSounds() {
        deviceClickPlayer = loadSound(named: "device_click")
        detailClickPlayer = loadSound(named: "detail_click")

        deviceClickPlayer?.volume = 0.5
        detailClickPlayer?.volume = 0.4
    }

    private func loadSound(named name: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            print("SoundManager: Could not find sound file '\(name).wav'")
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            print("SoundManager: Could not load sound '\(name)': \(error.localizedDescription)")
            return nil
        }
    }
}
