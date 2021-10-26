//
//  AudioPermission.swift
//  iosYeoboya
//
//  Created by cschoi724 on 09/09/2019.
//  Copyright © 2019 Inforex. All rights reserved.
//

import Foundation
import MobileCoreServices
import Photos
import UIKit

protocol AudioPermission{}
extension AudioPermission{
    
    /**
     * 오디오 권한 요청
     *********************************************/
    static func requestAuthorizationAudio(_ completion : ((Bool) -> Void)? = nil){
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            if let completion = completion{ completion(granted)}
        }
    }
    
    func requestAuthorizationAudio(_ completion : ((Bool) -> Void)? = nil){
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            if let completion = completion{ completion(granted)}
        }
    }
    
    func requestManualyAuthorization(cancel : (() -> Void)? = nil){
        let title = "마이크 권한 설정"
        let message = "방송을 하기 위해서는 [마이크]권한 설정이 필요합니다.\n설정>앱 권한에서 [마이크]를 켜주세요"
        
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
