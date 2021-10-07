//
//  RecordCell.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/28.
//

import UIKit
import AVFoundation
import RxSwift

class RecordCell: UICollectionViewCell {
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    
    var m4aURLString: String? = ""
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var playTimer: Timer?
    
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
        
    }
    
    func bind() {
        playBtn.rx.tap
            .bind {
                self.repeatUpdateRecordTimer()
                // timer < maxSec 눌럿을때 버튼 조정
                
                // timer >= maxSec 일때 stop 해주고 이미지 초기로 설정
                
            }.disposed(by: bag)
    }
    
    func repeatUpdateRecordTimer() {
        self.playTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(playControlProgress), userInfo: nil, repeats: true)
    }
    
    @objc func playControlProgress() {
        
    }
    
}
