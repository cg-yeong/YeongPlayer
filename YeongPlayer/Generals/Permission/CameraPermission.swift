//
//  CameraPermission.swift
//  iosYeoboya
//
//  Created by cschoi724 on 09/09/2019.
//  Copyright © 2019 Inforex. All rights reserved.
//

import UIKit
import Photos

protocol CameraPermission{}
extension CameraPermission{
    
    /**
     * 카메라 권한 요청
     *********************************************/
    static func requestAuthorizationCamera(_ completion : ((Bool) -> Void)? = nil){
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if let completion = completion{ completion(response)}
        }
    }
    
    func requestAuthorizationCamera(_ completion : ((Bool) -> Void)? = nil){
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if let completion = completion{ completion(response)}
        }
    }
    
    func requestManualyAuthorizationCamera(cancel : (() -> Void)? = nil){
        let title = "카메라 권한 설정 "
        let message = "영상 촬영을 하기 위해서는 [카메라]권한 설정이 필요합니다.\n설정>앱 권한에서 [카메라]를 켜주세요"
        
        DispatchQueue.main.async {
            Alert.message(title: title, message: message, cancelAction : {}) {
                if let url = URL(string: UIApplication.openSettingsURLString){
                    UIApplication.openURL(url: url)
                }
            }
        }
    }
}
