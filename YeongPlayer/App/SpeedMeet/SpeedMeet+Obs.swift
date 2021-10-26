//
//  SpeedMeet+Obs.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/24.
//

import UIKit
import Photos

extension VoiceRecordView {
    
    func addObserver() {
        let tapv = UITapGestureRecognizer(target: self, action: #selector(taptapv))
        chatCollectionView.addGestureRecognizer(tapv)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        PHPhotoLibrary.shared().register(self)
    }
    
    
    @objc func keyboardWillShow(_ sender: NSNotification) {
        let userInfo = sender.userInfo!
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if let window = UIApplication.shared.windows.first {
                let bottomPadding = window.safeAreaInsets.bottom
                self.stopAudio()
                self.recordIntputView.isHidden = true
                self.inputBaseView.isHidden = true
                
//                let webheight = self.web.scrollView.contentSize.height
//                let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.keyboardConstraint.constant, right: 0)
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
                    self.keyboardConstraint.constant = keyboardSize.height - bottomPadding
                    log.d(self.keyboardConstraint.constant)
//                    self.web.scrollView.contentInset = contentInset
//                    self.web.scrollView.scrollIndicatorInsets = contentInset
//                    self.web.scrollView.contentOffset = CGPoint(x: self.web.scrollView.contentOffset.x, y: 0 + self.keyboardConstraint.constant)
                    //self.chatContainerView.frame.size.height = self.chatContainerView.frame.size.height - self.keyboardConstraint.constant
                    self.layoutIfNeeded()
                } completion: { _ in
                    
                }
            }
            
        }
    }
    @objc func keyboardWillHide(_ sender: NSNotification) {
        
        let userInfo = sender.userInfo!
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        if self.inputBaseView.isHidden {
            UIView.animate(withDuration: duration) {
                self.keyboardConstraint.constant = 0
                self.layoutIfNeeded()
            } completion: { _ in
                
            }
        }
        
        

        
        
    }
    @objc func taptapv() {
        self.txtInput.resignFirstResponder()
        
        self.stopAudio()
        UIView.animate(withDuration: 0.25) {
            self.recordIntputView.isHidden = true
            self.inputBaseView.isHidden = true
            self.keyboardConstraint.constant = 0
            self.layoutIfNeeded()
        }
        self.layoutIfNeeded()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}
