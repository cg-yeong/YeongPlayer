//
//  SetViewers.swift
//  YeongPlayer
//
//  Created by inforex on 2021/11/01.
//

import UIKit
import RxSwift
import RxCocoa

class SetViewers: XibView {
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var manualInputField: UITextField!
    @IBOutlet weak var updateSetViewers: UIButton!
    
    let bag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        config()
        manualInputField.delegate = self
        
        
    }
    
    func config() {
        let without = UITapGestureRecognizer()
        mainView.addGestureRecognizer(without)
        
        without.rx.event
            .bind { _ in
                if self.manualInputField.isEditing {
                    self.manualInputField.endEditing(true)
                } else {
                    self.removeFromSuperview()
                }
                
            }.disposed(by: bag)
        
        
        
        updateSetViewers.rx.tap
            .bind {
                self.removeViewListenr = {
                    
                }
                if let setView = App.module.presenter.beforeView as? TVSetting {
                    setView.removeViewListenr = {
                        
                    }
                    
                }
            }.disposed(by: bag)
        
    }
    
    
}

extension SetViewers: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let char = string.cString(using: .utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        
        guard textField.text!.count < 4 else { return false }
        return true
    }
}
