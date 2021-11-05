//
//  TV+Obs.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/27.
//

import Foundation
import AVFoundation
import SwiftyJSON

extension TV {
    
    /* 옵저버 선언 */
    func addObserver() {
        // 키보드 오르내림
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 앱 백그라운드포그라운드
    }
    
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        let userInfo = notification.userInfo!
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let options = UIView.AnimationOptions(rawValue: curve << 16)
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let bottomPadding = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
            self.constSpaceFromChatContainerView.constant = keyboardSize.height - bottomPadding
            self.gift_constraint_bottom.constant = keyboardSize.height - bottomPadding
            
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                self.layoutIfNeeded()
                self.likeBtn.isHidden = true
                self.chatSendBtn.isHidden = false
            }, completion: nil)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        let userInfo = notification.userInfo!
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let options = UIView.AnimationOptions(rawValue: curve << 16)
        
        if self.constSpaceFromChatContainerView.constant != 0 {
            self.constSpaceFromChatContainerView.constant = 0
        }
        if self.gift_constraint_bottom.constant != 0 {
            self.gift_constraint_bottom.constant = 0
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.layoutIfNeeded()
            self.chatSendBtn.isHidden = true
            self.likeBtn.isHidden = false
        }, completion: nil)
    }
}
