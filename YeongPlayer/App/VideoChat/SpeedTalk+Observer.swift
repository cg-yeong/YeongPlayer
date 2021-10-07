//
//  SpeedTalk+Observer.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/16.
//

import UIKit

extension VideoChatView: UITextFieldDelegate {
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        if let keyboardSize = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.constSpaceToFooterFromChatContainer.constant = keyboardSize.height - (self.frame.maxY - footerView.frame.minY)
            
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                log.d(keyboardSize.height)
                self.layoutIfNeeded()
            
            }, completion: nil)
            
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let userInfo = notification.userInfo!
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        if constSpaceToFooterFromChatContainer.constant != 0 {
            self.constSpaceToFooterFromChatContainer.constant = 0
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            
            self.layoutIfNeeded()
        
        }, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.chatView.isHidden = true
        self.chatTextField.resignFirstResponder()
//        self.endEditing(true)
        return true
    }
}
