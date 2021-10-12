//
//  ImagePickerAuthorization.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/12.
//

import Foundation
import RxSwift
import Photos

class ImagePickerAuthorization {
    
    // 비디오 사용불가 관찰
    private let videoDisableSubject = BehaviorSubject<Bool>(value: true)
    
    let videoDisable: Observable<Bool>
    var videoDisableValue: Bool {
        let defaultValue = true
        return (try? videoDisableSubject.value()) ?? defaultValue
    }
    
    init() {
        self.videoDisable = self.videoDisableSubject.asObservable()
    }
    
    func checkAuthorizaitonStatus() {
        checkVideoAuthorizationStatus()
    }
    
    // 시뮬레이터일때 비디오 사용불가
    private var isSimulator: Bool {
        #if (!arch(i386) && !arch(x86_64))
        return false
        #else
        return true
        #endif
    }
    
    // 시뮬레이터, 비디오 사용권한잇을 때 사용가능 판정 전달
    private func checkVideoAuthorizationStatus() {
        if self.isSimulator {
            self.videoDisableSubject.onNext(true)
            return
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            self.videoDisableSubject.onNext(false)
        case .denied, .restricted:
            self.videoDisableSubject.onNext(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                self.videoDisableSubject.onNext(!granted)
            })
        @unknown default:
            fatalError()
        }
    }
    
}
