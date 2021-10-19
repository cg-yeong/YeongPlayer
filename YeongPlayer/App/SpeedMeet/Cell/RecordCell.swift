//
//  RecordCell.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/28.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

protocol CellPlayDelegate {
    func cellPlay(_ index: Int)
}

class RecordCell: UICollectionViewCell {
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    
    var m4aURLString: String? = ""
    var idx = 0
//    var player: AVAudioPlayer?
    
    var playTimer: Timer?
    
    var cellDelegate: CellPlayDelegate?
    
    let msgPlayer = RecordMsgPlayer.shared
    var arr = [RecordingMsg]()
    let bag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        initialize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func initialize() {
        setView()
        bind()
    }
    
    func setView() {
        playBtn.layer.cornerRadius = playBtn.bounds.size.width / 2
        
    }
    
    func bind() {
        playBtn.rx.tap
            .bind {
                DispatchQueue.main.async {
                    self.repeatUpdateRecordTimer()
                }
                if self.msgPlayer.isPlaying {
//                    self.msgPlayer.play()
                    self.cellPlay()
                } else {
                    self.msgPlayer.pause()
                }
                // timer < maxSec 눌럿을때 버튼 조정
                // timer >= maxSec 일때 stop 해주고 이미지 초기로 설정
                
            }.disposed(by: bag)
    }
    
    func playAudioFile(_ index: Int) {
        do {
            var action = try AVAudioPlayer(contentsOf: arr[index] as! URL)
            action.numberOfLoops = 0
            action.prepareToPlay()
            action.volume = 1
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func repeatUpdateRecordTimer() {
        self.playTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(playTimeControlProgress), userInfo: nil, repeats: true)
    }
    
    @objc func playTimeControlProgress() {
        if msgPlayer.player.isPlaying {
            self.playTime.text = "\(msgPlayer.totalDurationTime - msgPlayer.currentTime)"
            self.progress.setProgress(Float(msgPlayer.totalDurationTime), animated: true)
        } else {
            self.playTime.text = "\(msgPlayer.totalDurationTime)"
            self.progress.setProgress(0, animated: false)
        }
    }
    
    @objc func cellPlay() {
        cellDelegate?.cellPlay(idx)
    }
    
}
