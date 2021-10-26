//
//  alert.swift
//  iosBang
//
//  Created by SCC-PC on 2019. 1. 22..
//  Copyright © 2019년 Inforex. All rights reserved.
//

import Foundation
import UIKit


public class Alert : NotifyDelegate {
    // 현재 device orientation 에 따라 alertview 도 회전 시켜준다, 기본 값은 화면 고정
    static var alertVC : UIViewController?
    public static var rotated : Bool = false
    
    /* UIAlertController를 생성해 화면에 present */
    fileprivate static func setAlert(title: String, message: String, actions : [UIAlertAction]){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions{
            alertController.addAction(action)
        }
        if let execute = self.viewController {
            rotate(alertController)
            execute.present(alertController, animated: false, completion: nil)
        }
        alertVC = alertController
    }
    
    /*
     * defult action : 확인, 취소
     * 단순한 alert 에 사용
     */
    public static func message(title: String = "",message: String = "", rotated : Bool = false,
                               cancelAction :  (()->Void)? = nil, singleAction :  (()->Void)? = nil){
        
        var actions : [UIAlertAction] = []
        if let singleAction = singleAction{
            let action = UIAlertAction(title: "확인", style: .default) { _ in  singleAction()  }
            actions.append(action)
        }
        
        if let cancelAction = cancelAction{
            let action = UIAlertAction(title: "취소", style: .cancel) { _ in  cancelAction()  }
            actions.append(action)
        }

        setAlert(title: title, message: message, actions: actions)
    }
    
    /*
     * custom action
     * 다양한 alert 타입에 사용한다
     */
    public static func message(title: String = "",message: String = "", rotated : Bool = false, actions :  UIAlertAction...) {
        setAlert(title: title, message: message, actions: actions)
    }
    
    // alert view를 회전 시킨다
    public static func rotate(_ alertController : UIAlertController){
        if rotated {
            switch UIDevice.current.orientation {
            case .landscapeRight:
                alertController.view.transform=CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
            case .landscapeLeft:
                alertController.view.transform=CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
            default:
                alertController.view.transform=CGAffineTransform.identity
            }
        }
    }
}
extension UIAlertController{
    override open func viewWillAppear(_ animated: Bool) {
        view.isHidden = true
    }
    override open func viewDidAppear(_ animated: Bool) {
        view.isHidden = false
    }
    override open func viewWillDisappear(_ animated: Bool) {
        view.isHidden = true
        Alert.alertVC = nil
    }
}
