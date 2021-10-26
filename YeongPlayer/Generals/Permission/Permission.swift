//
//  Authority.swift
//  iosBang
//
//  Created by cschoi724 on 04/06/2019.
//  Copyright © 2019 Inforex. All rights reserved.
//
import Foundation
import UIKit
import Photos
import CoreLocation
import MobileCoreServices
import Contacts
import UserNotifications

  // 위치,푸시,앨범,카메라,음성, 주소록
class Permission : ContactPermission, PhotosPermission, NotificationPermission, AudioPermission, CameraPermission, LocationPermission {
    enum requestType{ case Location, Notification, Photos, Camera, Microphone, Contact }
    static let sharedInstance: Permission = { return Permission() }()
    var clLocationManager : CLLocationManager = CLLocationManager()
    
    func request(_ type : requestType, completeHandler : ((Bool) -> Void)? = nil){
        switch type {
        case .Location: requestAuthorizationLocation(completeHandler)
        case .Notification: requestAuthorizationNotification(completeHandler)
        case .Photos: requestAuthorizationPhotos(completeHandler)
        case .Camera: requestAuthorizationCamera(completeHandler)
        case .Microphone: requestAuthorizationAudio(completeHandler)
        case .Contact: requestAuthorizationContact(completeHandler)
        }
    }
    
    /* 정적 권한 요청
     * 위치서비스는 정적으로 요청할 수 없다
     */
    class func request(_ type : requestType, completeHandler : ((Bool) -> Void)? = nil){
        switch type {
        case .Location: if let completion  = completeHandler { completion(false) }
        case .Notification: requestAuthorizationNotification(completeHandler)
        case .Photos: requestAuthorizationPhotos(completeHandler)
        case .Camera: requestAuthorizationCamera(completeHandler)
        case .Microphone: requestAuthorizationAudio(completeHandler)
        case .Contact: requestAuthorizationContact(completeHandler)
        }
    }
    

    func manualyAuthorization(_ type : requestType, _ cancel : (() -> Void)? = nil){
        var title = "" , message = ""
        switch type {
        case .Location:
            title = "위치 권한 설정"
            message = "앱을 정상적으로 사용하기 위해서는 [위치]권한 설정이 필요합니다.\n설정>앱 권한에서 [위치]를 켜주세요"
        case .Notification:
            title = "알림 권한 설정"
            message = "앱을 정상적으로 사용하기 위해서는 [알림]권한 설정이 필요합니다.\n설정>앱 권한에서 [알림]를 켜주세요"
        case .Photos:
            title = "사진/미디어 권한 설정 "
            message = "앨범에 저장된 사진(동영상)을 등록하기 위해서는 [사진]권한 설정이 필요합니다.\n설정>앱 권한에서 [사진]을 켜주세요"
        case .Camera:
            title = "카메라 권한 설정 "
            message = "사진(동영상) 촬영 후 업로드를 하기 위해서는 [카메라]권한 설정이 필요합니다.\n설정>앱 권한에서 [카메라]를 켜주세요"
        case .Microphone:
            title = "마이크 권한 설정"
            message = "사진(동영상) 촬영 후 업로드를 하기 위해서는 [마이크]권한 설정이 필요합니다.\n설정>앱 권한에서 [마이크]를 켜주세요"
        case .Contact:
            title = "주소록 권한 설정"
            message = "주소록 자동저장 기능을 이용하기 위해서는 [주소록]권한 설정이 필요합니다.\n설정>앱 권한에서 [주소록]을 켜주세요"
        }
        
        DispatchQueue.main.async {
            Alert.message(title: title, message: message, cancelAction : cancel) {
                if let url = URL(string: UIApplication.openSettingsURLString){
                    UIApplication.openURL(url: url)
                }                
            }
        }
    }
}


