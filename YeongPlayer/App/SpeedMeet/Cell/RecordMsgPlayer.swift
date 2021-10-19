//
//  RecordMsgPlayer.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/28.
//

import UIKit
import AVFoundation
import MediaToolbox
import MediaPlayer

class RecordMsgPlayer {
    
    static let shared = RecordMsgPlayer()
    
    let player = AVAudioPlayer()
//    private let ppp = AVPlayer()
    
    var currentTime: Double {
        return player.currentTime
    }
    
    var totalDurationTime: Double {
        return player.duration
    }
    
    var isPlaying: Bool {
        player.isPlaying
    }
    
//    var currentItem: <- url or data
    
    init() { }
    
    func pause() {
        player.pause()
    }
    
    func play() {
        player.play()
    }
    
//    func seek() {}
    
    
    
}
