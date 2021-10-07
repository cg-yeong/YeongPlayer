//
//  VideoEditorVC.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/10.
//

import Foundation
import UIKit
import AVFoundation
import Photos
import AVKit
import RxSwift
import RxCocoa

class VideoEditorVC: UIViewController {
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var videoContainer: UIView!
    
    @IBOutlet weak var rangeSlider: ABVideoRangeSlider!
    @IBOutlet weak var selectedPlayTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    var videoPath: String!
    var from = "camera"
    
    var avPlayer: AVPlayer! = nil
    var avPlayerLayer: AVPlayerLayer! = nil
    var startTime = 0.0
    var endTime = 0.0
    var progressTime = 0.0
    var isSeeking = false
    var timeObserver: AnyObject!
    
    var shouldUpdateProgressIndicator = true
    var img: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageview.image = img
        print(videoPath)
        self.readyMovie()
        self.avPlayer.currentItem?.addObserver(self, forKeyPath: "status", options: [.initial, .new], context: nil)
        
        
        self.selectedPlayTimeLabel.layer.cornerRadius = 4.0
        self.selectedPlayTimeLabel.layer.masksToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avPlayerLayer.frame = videoContainer.bounds
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func readyMovie() {
        if self.avPlayer == nil {
            self.avPlayer = AVPlayer()
        }
        
        let playerItem = AVPlayerItem(url: URL(fileURLWithPath: self.videoPath))
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        
        videoContainer.layer.insertSublayer(avPlayerLayer, at: 0)
        videoContainer.layer.masksToBounds = true
        
        
        
    }
    func playVideo() {
        if self.avPlayer.rate == 0 {
            avPlayer.play()
        }
    }
    func pauseVideo() {
        avPlayer.pause()
    }
    
    func clearVC() {
        avPlayer.pause()
        timeObserver.invalidate()
        avPlayer.replaceCurrentItem(with: nil)
    }
    
    @IBAction func goSend() {
        pauseVideo()
        gotrimVideo()
    }
    
    func gotrimVideo() {
        var sourceURL: URL!
        var timeScale: Int32!
        
        pauseVideo()
        
        sourceURL = URL(fileURLWithPath: self.videoPath)
        timeScale = 1000
        
        var destURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        destURL.appendPathComponent("clubIosVideoFile2.mp4")
        
        let trimPoint = (CMTimeMakeWithSeconds(startTime, preferredTimescale: timeScale), CMTimeMakeWithSeconds(endTime, preferredTimescale: timeScale))
        // self.trimvideo( diafsjfa )
    }
    
    func observeTime(elpasedTIme: CMTime) {
        let elpasedTime = CMTimeGetSeconds(elpasedTIme)
        
        if avPlayer.currentTime().seconds >= self.endTime {
            self.pauseVideo()
            self.playVideo()
        }
        
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if self.avPlayer.currentItem?.status == AVPlayerItem.Status.readyToPlay {
            DispatchQueue.main.async {
                let totalDuration = CMTimeGetSeconds((self.avPlayer.currentItem?.duration)!)
                if totalDuration.isNaN { return }
                
                self.avPlayer.currentItem?.removeObserver(self, forKeyPath: "status")
                
                let timeInterval: CMTime = CMTimeMakeWithSeconds(0.1, preferredTimescale: 100)
                self.timeObserver = self.avPlayer.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { (elpasedTime) in
                    self.observeTime(elpasedTIme: elpasedTime)
                }) as AnyObject
                
                self.endTimeLabel.text = Int(totalDuration).toColonTime
                
                if totalDuration > 60 {
                    self.endTime = Double(60)
                } else {
                    self.endTime = totalDuration
                }
                self.selectedPlayTimeLabel.text = Int(self.endTime).toColonTime + " 선택됨"
                
                self.playVideo()
            }
        }
    }
    
    
    
    // ABVideoRangeSlider Delegate
    func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
        shouldUpdateProgressIndicator = false
        pauseVideo()
        
    }
    
    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
        self.endTime = endTime
        
        if startTime != self.startTime {
            self.startTime = startTime
            
            let timescale = avPlayer.currentItem?.asset.duration.timescale
            
        }
    }
    
}


