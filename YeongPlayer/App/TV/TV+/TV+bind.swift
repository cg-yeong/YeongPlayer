//
//  TV+bind.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/27.
//

import Foundation
import RxSwift
import RxCocoa

extension TV {
    
    func bind() {
        
        let detail_tap = UITapGestureRecognizer()
        let floating_camera_tap = UITapGestureRecognizer()
        
        self.addGestureRecognizer(detail_tap)
        floating_camera_view.addGestureRecognizer(floating_camera_tap)
        self.addGestureRecognizer(videoView_pan)
        
        detail_tap.rx.event
            .bind { _ in
                if self.chatInput.isEditing {
                    self.chatDown()
                    return
                }
                self.detailTapped()
            }.disposed(by: bag)
        
        floatingToggleBtn.rx.tap
            .bind { (_) in
                
                self.toggleFloating()
                
            }.disposed(by: bag)
        
        floating_camera_tap.rx.event
            .bind { _ in
                self.toggleFloating()
            }.disposed(by: bag)
        
        floating_change_btn.rx.tap
            .bind { _ in
                self.toggleFloating()
            }.disposed(by: bag)
        
        exitLiveBtn.rx.tap
            .bind { _ in
                self.removeFromSuperview()
            }.disposed(by: bag)
        
        floating_exit_btn.rx.tap
            .bind { _ in
//                self.exitPopup() // 알럿으로 종료할거냐고 물어보기
                self.removeFromSuperview()
            }.disposed(by: bag)
        
        videoView_pan.rx.event
            .bind { _ in
                self.viewViewPanning(self.videoView_pan)
            }.disposed(by: bag)
        
        giftBtn.rx.tap
            .bind { _ in
                self.chatDown()
//                self.toggleGiftLayer()
            }.disposed(by: bag)
        
    }
    
}
