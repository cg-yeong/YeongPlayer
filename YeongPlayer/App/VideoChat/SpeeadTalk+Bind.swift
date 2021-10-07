//
//  VideoChatView+bind.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/16.
//

import UIKit
import RxCocoa
import RxSwift

extension VideoChatView {
    
    func bind() {
        chat.rx.tap
            .bind {
                self.loadingIndicator.stopAnimating()
            }.disposed(by: bag)
        
        mic.rx.tap
            .bind {
                self.mic.isSelected = !self.mic.isSelected
                
            }.disposed(by: bag)
        
        callDone.rx.tap
            .bind {
                self.removeFromSuperview()
            }.disposed(by: bag)
        
        sound.rx.tap
            .bind {
                self.sound.isSelected = !self.sound.isSelected
            }.disposed(by: bag)
        
        like.rx.tap
            .bind {
                
            }.disposed(by: bag)
        
        mineViewBtn.rx.tap
            .bind {
                self.mineViewBtn.isSelected = !self.mineViewBtn.isSelected
            }.disposed(by: bag)
        
        rewardBtn.rx.tap
            .bind {
                self.rewardPopupView.isHidden = !self.rewardPopupView.isHidden
                self.rewardBtn.isSelected = !self.rewardBtn.isSelected
            }.disposed(by: bag)
        
        likeRankBtn.rx.tap
            .bind {
                self.rankPopupView.isHidden = !self.rankPopupView.isHidden
            }.disposed(by: bag)
        
    }
}
