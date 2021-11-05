//
//  CHAlert.swift
//  iosClubRadio
//
//  Created by cschoi724 on 2020/04/08.
//  Copyright © 2020 Inforex. All rights reserved.
//

import Foundation

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
    static func CustomAlert(on : Presenter.OnController = .visibleView, _ title : String, leftAction: AlertAction, rightAction: AlertAction){
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //옛날꺼 기본 알림 창
//    static func myAlert(_ title: String, message: String, okLabel: String, okPressed: (()->Void)?) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: okLabel, style: .default, handler: {(action) in
//            if let okCallback = okPressed {
//                okCallback()
//            }
//        })
//        alertController.addAction(okAction)
//        DispatchQueue.main.async {
//            getNavigationController().present(alertController, animated: false, completion: nil)
//        }
//    }
//    
//    //옛날꺼 기본 알림 창
//    static func myConfirm(_ title: String, message: String, cancelLabel: String, okLabel: String, cancelPressed: (()->Void)?, okPressed: (()->Void)?) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: cancelLabel, style: .default, handler: {(action) in
//            if let cancelCallback = cancelPressed {
//                cancelCallback()
//            }
//        })
//        let okAction = UIAlertAction(title: okLabel, style: .default, handler: {(action) in
//            if let okCallback = okPressed {
//                okCallback()
//            }
//        })
//        alertController.addAction(cancelAction)
//        alertController.addAction(okAction)
//        DispatchQueue.main.async {
//            getNavigationController().present(alertController, animated: false, completion: nil)
//        }
//    }
}
