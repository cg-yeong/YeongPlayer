//
//  PhotosPermission.swift
//  iosYeoboya
//
//  Created by cschoi724 on 09/09/2019.
//  Copyright © 2019 Inforex. All rights reserved.
//

import UIKit
import Photos

protocol PhotosPermission{}
extension PhotosPermission{
    
    /**
     * 사진 권한 요청
     *********************************************/
    static func requestAuthorizationPhotos(_ completion : ((Bool) -> Void)? = nil){
        PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
            if let completion = completion{
                if status == .authorized { completion(true) }
                else{ completion(false) }
            }
        })
    }
    
    func requestAuthorizationPhotos(_ completion : ((Bool) -> Void)? = nil){
        PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
            if let completion = completion{
                if status == .authorized { completion(true) }
                else{ completion(false) }
            }
        })
    }
    
    func requestManualyAuthorization(cancel : (() -> Void)? = nil){
        let title = "사진/미디어 권한 설정 "
        let message = "앨범에 저장된 사진을 등록하기 위해서는 [사진]권한 설정이 필요합니다.\n설정>앱 권한에서 [사진]을 켜주세요"
        
        DispatchQueue.main.async {
            Alert.message(title: title, message: message, cancelAction : {}) {
                if let url = URL(string: UIApplication.openSettingsURLString){
                    UIApplication.openURL(url: url)
                }
                log.d("hi")
            }
        }
    }
}
