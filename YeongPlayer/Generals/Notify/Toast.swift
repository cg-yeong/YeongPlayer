//
//  Toast.swift
//  iosWork
//
//  Created by cschoi724 on 12/03/2019.
//  Copyright © 2019 Inforex. All rights reserved.
//

import Foundation
import Toast_Swift


public class Toast : NotifyDelegate{

    class func showOnNavigation(_ message : String, duration : Double = 3.0, position : ToastPosition = .center, title : String? = nil, image: UIImage? = nil, completion: ((Bool)->Void)? = nil){
        var style = ToastStyle()
        style.titleAlignment = .center
        style.messageAlignment = .center
        style.horizontalPadding = 20
        self.navigationController?.view.makeToast(message, duration: duration, position: position, title: title, image: image, style: style, completion: completion)
    }
    
    class func show(_ message : String,
                    on: Presenter.OnController = .navigationView,
                    duration : Double = 2.0,
                    fontColor: UIColor? = .white,
                    position : ToastPosition = .center,
                    title : String? = nil,
                    image: UIImage? = nil,
                    completion: ((Bool)->Void)? = nil){
        
        var style = ToastStyle()
        style.titleAlignment = .center
        style.messageAlignment = .center
        style.horizontalPadding = 20
        style.messageColor = fontColor ?? .white
        
        guard let vc = App.module.presenter.onViewController(on) else{
             return
         }
                
        vc.view.hideAllToasts()
        vc.view.clearToastQueue()
        
        vc.view.makeToast(message,
                          duration: duration,
                          position: position,
                          title: title,
                          image: image,
                          style: style,
                          completion: completion)
    }
   
}
