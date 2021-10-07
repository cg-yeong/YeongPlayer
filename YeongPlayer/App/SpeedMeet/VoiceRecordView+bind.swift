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
        
        fileAlbum.rx.tap
            .bind {
                self.endEditing(true)
                self.recordIntputView.isHidden = true
                
                if self.keyboardConstraint.constant != 0 {
                    if !self.albumInputView.isHidden {
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
                
                self.albumInputView.isHidden.toggle()
                self.fileAlbum.isSelected.toggle()
            }.disposed(by: bag)
        
        getMediaAlbum.rx.tap
            .bind {
                // 권한 먼저 묻기
                Utility.askPhotoAuthorization { (photoGranted) in
                    if photoGranted {
                        DispatchQueue.main.async {
                            let editorVC = UIStoryboard(name: "PhotoMain", bundle: nil).instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
                            editorVC.modalPresentationStyle = .fullScreen
                            // editorVC.jsonData = data
                            //App.module.presenter.visibleViewController?.present(editorVC, animated: true, completion: nil)
                            UIApplication.shared.windows.first?.rootViewController?.present(editorVC, animated: true, completion: nil)
                        }
                    } else {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            if #available(iOS 10.0, *) {
                                DispatchQueue.main.async {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }                            } else {
                                UIApplication.shared.openURL(url)
                            }
                        }
                    }
                }
            }.disposed(by: bag)
        
        recordInputBtn.rx.tap
            .bind {
                self.endEditing(true)
                self.albumInputView.isHidden = true
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
                self.recordInputBtn.isSelected.toggle()
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
                            Toast.showOnXib("구매페이지로 이동하기~")
                        }
                        return
                    }
                    // 보내기
                    
                }
                if self.audioPlayer != nil {
                    if self.audioPlayer!.duration < TimeInterval(self.recordModel.minSec)! {
                        // 최소 시간 체크
                        Toast.showOnXib("\(self.recordModel.minSec)초 이상 녹음해주세요~")
                    } else {
                        self.sendFile()
                    }
                }
                
            }.disposed(by: bag)
    }
    
    
}
