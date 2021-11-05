//
//  BasicAlertView.swift
//  iosClubRadio
//
//  Created by cschoi724 on 2020/04/08.
//  Copyright © 2020 Inforex. All rights reserved.
//

import Foundation
import RxSwift

/*
 녹음 리뉴얼에 쓰이는 팝업
*/
class RecordAlert : XibView{
    
    @IBOutlet weak var super_view: UIView!
    @IBOutlet weak var title_message_label: UILabel!
    @IBOutlet weak var message_label: UILabel!
    @IBOutlet weak var action_btn: UIButton!
    
    var message : String = ""
    var action : (() -> Void) = {}
    var disposbag = DisposeBag()
    let gradient: CAGradientLayer = CAGradientLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isInitialized {
            initialize()
            isInitialized = false
        }
        gradient.frame = action_btn.bounds
    }
    
    func initialize(){
        
        if !message.isEmpty {
            message_label.text = message
        }
        
        action_btn.rx.tap
            .bind { (_) in
                self.action()
                self.removeFromSuperview()
            }
            .disposed(by: disposbag)
        

    }
}
