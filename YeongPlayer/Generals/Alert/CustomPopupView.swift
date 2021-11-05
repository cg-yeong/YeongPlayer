//
//  VSAlertView.swift
//  chat-radar
//
//  Created by eunhye on 05/02/2020.
//  Copyright © 2020 inforex. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/*
 최대 5줄 사이즈로 크기 고정되어 있는 팝업(안드로이드 디자인).
*/
class CustomPopupView: XibView{

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var cancelSetBtn: UIButton!
    @IBOutlet weak var okSetBtn: UIButton!
    
    fileprivate var completionHandler : (() -> Void)?
    fileprivate var cancelHandler : (() -> Void)?
    
    var message : String = ""
    var attributeText : NSMutableAttributedString!
    var leftText : String = "아니오"
    var rightText : String = "예"
    var leftAction : () -> Void = {}
    var rightAction : () -> Void = {}
    var disposbag = DisposeBag()
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isInitialized {
            initialize()
            isInitialized = false
        }
    }
    
    func initialize(){
        
        if !message.isEmpty {
            textLabel.text = message
        }else if attributeText != nil{
            textLabel.attributedText = attributeText
        }
        
        cancelSetBtn.setTitle(leftText, for: .normal)
        okSetBtn.setTitle(rightText, for: .normal)

        cancelSetBtn.rx.tap
            .bind { (_) in
                self.leftAction()
                self.removeFromSuperview()
            }
            .disposed(by: disposbag)
        
        okSetBtn.rx.tap
            .bind { (_) in
                self.rightAction()
                self.removeFromSuperview()
            }
            .disposed(by: disposbag)
    }
    
    func setAttributeText(_ attributeText : NSAttributedString){
        textLabel.attributedText = attributeText
    }
}
