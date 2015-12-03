//
//  SoundSettings.swift
//  Codebusters_sample
//
//  Created by Владислав Кутейников on 18.09.15.
//  Copyright (c) 2015 Kids'n'Code. All rights reserved.
//


import Foundation
import SpriteKit
import AVFoundation

public class AudioPlayer {
    public static let sharedInstance = AudioPlayer()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayer: AVAudioPlayer?
    
    var soundsAreOn: Bool
    var musicIsOn: Bool
    
    init() {
        let defaults = NSUserDefaults.standardUserDefaults()

        if let music = defaults.objectForKey("music") as? Bool, let sounds = defaults.objectForKey("sounds") as? Bool {
            musicIsOn = music
            soundsAreOn = sounds
        } else {
            defaults.setBool(true, forKey: "music")
            defaults.setBool(true, forKey: "sounds")
        
            musicIsOn = true
            soundsAreOn = true
        }
    }
    
    public func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
    
        var error: NSError? = nil
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: url!)
        } catch let error1 as NSError {
            error = error1
            backgroundMusicPlayer = nil
        }
        if let player = backgroundMusicPlayer {
            player.numberOfLoops = -1
            player.prepareToPlay()
            if musicIsOn {
                player.play()
            }
        } else {
            print("Could not create audio player: \(error!)")
        }
    }
    
    public func pauseBackgroundMusic() {
        if let player = backgroundMusicPlayer {
            if player.playing {
                player.pause()
                musicIsOn = false
            }
        }
    }
    
    public func resumeBackgroundMusic() {
        if let player = backgroundMusicPlayer {
            if !player.playing {
                player.play()
                musicIsOn = true
            }
        }
    }
    
    public func playSoundEffect(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOfURL: url!)
        } catch let error1 as NSError {
            error = error1
            soundEffectPlayer = nil
        }
        if let player = soundEffectPlayer {
            if soundsAreOn {
                player.numberOfLoops = 0
                player.prepareToPlay()
                player.play()
            }
        } else {
            print("Could not create audio player: \(error!)")
        }
    }
}