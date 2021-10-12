//
//  CameraPermission.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/12.
//

import Foundation
import Photos
import UIKit

protocol CameraPermission {  }
extension CameraPermission {
    
    /// 카메라 권한 요청
    ///***************************
    static func requestAuthorization(_ completion: ((Bool) -> Void)? = nil) {
        AVCaptureDevice.requestAccess(for: .video) { response in
            if let completion = completion {
                completion(response)
            }
        }
    }
    
    func requestAuthorizationCamera(_ completion: ((Bool) -> Void)? = nil) {
        AVCaptureDevice.requestAccess(for: .video) { response in
            if let completion = completion {
                completion(response)
            }
        }
    }
    
    func requestManualyAuthorizationCamera(cancel: (() -> Void)? = nil) {
        let title = "카메라 권한 설정"
        let message = "영상 촬영을 하기 위해서는 [카메라] 권한 설정이 필요합ㄴ디ㅏ.\n 설정 > 앱 권한에서 [카메라]를 켜주세요"
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let ok = UIAlertAction(title: "확인", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            alert.addAction(cancel)
            alert.addAction(ok)
            (App.module.presenter.visibleViewController)?.present(alert, animated: false, completion: nil)
        }
    }
    
}

