//
//  Utility.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/05.
//

import Foundation
import Photos
import UIKit

class Utility: NSObject {
    
    static func removeFileAtURLIfExists(url: URL) {
        let filePath = url.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
            } catch let error {
                print(error)
            }
        }
    }
    
    class func delayExecute(_ delay: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: closure)
    }
    
    // 사진 라이브러리 사용에 대한 허가 체크 하고 없으면 요청
    static func askPhotoAuthorization(callback: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization() { (status) in
                if status == .authorized {
                    callback(true)
                } else {
                    callback(false)
                }
            }      
        case .restricted:
            callback(false)
        case .denied:
            callback(false)
        case .authorized:
            callback(true)
        case .limited:
            callback(false)
        @unknown default:
            fatalError()
        }
    }
    
    static func getStatusBarHeight() -> CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 20
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        
        return statusBarHeight
    }
    
}
