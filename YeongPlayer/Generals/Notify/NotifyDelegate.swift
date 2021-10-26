//
//  NotifyDelgate.swift
//  HelperKit
//
//  Created by cschoi724 on 20/08/2019.
//  Copyright © 2019 Inforex. All rights reserved.
//

import Foundation

protocol NotifyDelegate{
    static var viewController : UIViewController? {get}
    static var navigationController : UINavigationController? {get}
}
extension NotifyDelegate{
    static var viewController : UIViewController? {
        return App.module.presenter.visibleViewController
    }
    
    static var navigationController : UINavigationController? {
        return App.module.presenter.navigationViewController
    }
}
