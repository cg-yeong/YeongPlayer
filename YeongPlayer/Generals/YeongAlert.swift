//
//  YeongAlert.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/23.
//

import UIKit

class YeongAlert {
    
    static func baseAlert(message: String, rdoIt: (() -> Void)!) {
        let customAlert = UIAlertController(title: "주의!", message: message, preferredStyle: .alert)
        let leftAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let rightAction = UIAlertAction(title: "확인", style: .default) { act in
            rdoIt()
        }
        customAlert.addAction(leftAction)
        customAlert.addAction(rightAction)
        App.module.presenter.visibleViewController?.present(customAlert, animated: true, completion: nil)
    }
}
/*
 커스텀 알림창 총 관리
 */
class AlertAction {
    var title : String = ""
    var action : (() -> Void) = {}
    
    init(title : String = "", action : (()->Void)? = nil) {
        self.title = title
        if let doit = action {
            self.action = doit
        }else{
            self.action = {}
        }
    }
}

class CHAlert {
    static func CustomAlert(on : Presenter.OnController = .navigationView, _ title : String, leftAction: AlertAction, rightAction: AlertAction){
        App.module.presenter.addSubview(on, type: CustomPopupView.self){ view in
            view.message = title
            view.tag = 1010
            
            if !leftAction.title.isEmpty {
                view.leftText = leftAction.title
            }
            
            if !rightAction.title.isEmpty {
                view.rightText = rightAction.title
            }
            
            view.leftAction = leftAction.action
            view.rightAction = rightAction.action
        }
    }
    
    
    
    
    
