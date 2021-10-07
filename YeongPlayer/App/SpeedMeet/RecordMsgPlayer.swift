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

class RecordMsgPlayer: NSObject {
    
    static let player = RecordMsgPlayer()
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    
    func initPlayer() {
        do {
            UIApplication.shared.beginReceivingRemoteControlEvents()
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            log.d("AVAudioSession Category PlayBack OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                log.d("AVAudioSession is Active")
            } catch {
                log.d(error.localizedDescription)
            }
        } catch let error as NSError {
            log.d(error.localizedDescription)
        }
    }
    
    func playMsg(_ msgURL: String?) {
        if let rmurl = msgURL {
            var url: URL!
            url = URL(string: rmurl)
            playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            player?.volume = 1.0
            player?.rate = 1.0
            player?.play()
        }
    }
    
}
