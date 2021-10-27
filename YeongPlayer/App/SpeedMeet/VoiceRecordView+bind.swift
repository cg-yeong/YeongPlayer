//
//  VoiceRecordView+bind.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/23.
//

import UIKit
import RxSwift
import RxCocoa

extension VoiceRecordView {
    
    func bind() {
        
        backBtn.rx.tap
            .bind {
                self.removeFromSuperview()
            }.disposed(by: bag)
        
        moreBtn.rx.tap
            .bind {
                self.quitStack.isHidden.toggle()
            }.disposed(by: bag)
        
        quitChat.rx.tap
            .bind {
                self.removeFromSuperview()
            }.disposed(by: bag)
        
        reportQuitChat.rx.tap
            .bind {
                self.removeFromSuperview()
                Toast.show("임시 신고 테스트", on: .visibleView)
                
            }.disposed(by: bag)
        
        likeBtn.rx.tap
            .bind {
                
            }.disposed(by: bag)
        
        chatSendBtn.rx.tap
            .bind {
                self.sendMessage()
            }.disposed(by: bag)
        
        funcInputBtn.rx.tap
            .bind {
                self.endEditing(true)
                self.recordIntputView.isHidden = true

                if self.keyboardConstraint.constant != 0 {
                    if !self.inputBaseView.isHidden {
                        self.stopAudio()
                        UIView.animate(withDuration: 0.25) {
                            self.keyboardConstraint.constant = 0
                            self.layoutIfNeeded()
                        }
                    }
                } else {
                    UIView.animate(withDuration: 0.25) {
                        self.keyboardConstraint.constant = (self.txtInput.inputView?.frame.maxY) ?? 302

                        self.layoutIfNeeded()
                    }
                }

                self.inputBaseView.isHidden.toggle()
                self.funcInputBtn.isSelected.toggle()
            }.disposed(by: bag)
        
        movieBtn.rx.tap
            .bind {
                Utility.askMicAuthorization(callback: { (micGranted) in
                    if micGranted {
                        DispatchQueue.main.async {
                            
                        }
                    } else {
                        Permission.sharedInstance.manualyAuthorization(.Microphone)
                    }
                })
            }.disposed(by: bag)
        
        voiceBtn.rx.tap
            .bind {
                self.endEditing(true)
                self.inputBaseView.isHidden = true
                if self.keyboardConstraint.constant != 0 {
                    if !self.recordIntputView.isHidden {
                        self.stopAudio()
                        UIView.animate(withDuration: 0.25) {
                            self.keyboardConstraint.constant = 0
                            self.layoutIfNeeded()
                        }
                    }
                } else {
                    UIView.animate(withDuration: 0.25) {
                        self.keyboardConstraint.constant = (self.txtInput.inputView?.frame.maxY) ?? 250
                        self.layoutIfNeeded()
                    }
                }
                self.recordIntputView.isHidden.toggle()
                self.voiceBtn.isSelected.toggle()
            }.disposed(by: bag)
        
        
        recordingBtn.rx.tap
            .bind {
                self.motionRecord()
            }.disposed(by: bag)
        
        reRecordBtn.rx.tap
            .bind {
                if self.nowRecordState == .recordStop || self.nowRecordState == .playStop {
                    YeongAlert.baseAlert(message: "이전 녹음을 삭제하시겠습니까?") {
                        self.stopAudio()
                    }
                }
                
            }.disposed(by: bag)
        
        recordSendBtn.rx.tap
            .bind {
                let memSex = "m"
                let isVoucher = "y"
                if (memSex == "m" || memSex == "M") {
                    guard isVoucher == "y" else {
                        YeongAlert.baseAlert(message: "빠른만남 이용권이 필요한 서비스입니다.\n구매하시겠습니까?") {
                            Toast.show("구매페이지로 이동하기~", on: .visibleView)
                        }
                        return
                    }
                    // 보내기
                    
                }
                if self.audioPlayer != nil {
                    if self.audioPlayer!.duration < TimeInterval(self.recordModel.minSec)! {
                        // 최소 시간 체크
                        Toast.show("\(self.recordModel.minSec)초 이상 녹음해주세요~", on: .visibleView)
                    } else {
                        self.sendFile()
                    }
                }
                
            }.disposed(by: bag)
    }
    
    
}
