//
//  NotificationPermission.swift
//  iosYeoboya
//
//  Created by cschoi724 on 09/09/2019.
//  Copyright © 2019 Inforex. All rights reserved.
//

import Foundation
import UserNotifications


protocol NotificationPermission{}
extension NotificationPermission{
    
    /**
     * 푸시 노티 권한 요청
     *********************************************/
    static func requestAuthorizationNotification(_ completion : ((Bool) -> Void)? = nil){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (allow, err) in
            if let completion = completion{ completion(allow) }
        }
    }
    
    func requestAuthorizationNotification(_ completion : ((Bool) -> Void)? = nil){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (allow, err) in
            if let completion = completion{ completion(allow) }
        }
    }
}
