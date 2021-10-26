//
//  ImagePickerAuthorization.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/25.
//

import Foundation
import RxSwift
import Photos

class ImagePickerAuthorization {
    private let videoDisableSubjcet = BehaviorSubject<Bool>(value: true) // 초기값 비디오 사용불가능
    
    let videoDisable: Observable<Bool> // 비디오 사용불가 값 관찰되는 것
    var videoDisableValue: Bool {
        return self.videoDisableSubjcet.value(true)
    }
    
    init() {
        self.videoDisable = self.videoDisableSubjcet.asObservable()
    }
    
    func checkAuthorizationStatus() {
        checkVideoAuthorizationStatus()
    }
    
    private var isSimulator: Bool {
        #if (!arch(i386) && !arch(x86_64))
        return false
        #else
        return true
        #endif
    }
    
    private func checkVideoAuthorizationStatus() {
        if self.isSimulator {
            self.videoDisableSubjcet.onNext(true)
            return
        } // 시뮬레이터일때 비디오 사용불가능 전달
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            self.videoDisableSubjcet.onNext(false) // 비디오 사용 가능 전달
        case .denied, .restricted:
            self.videoDisableSubjcet.onNext(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                self.videoDisableSubjcet.onNext(!granted)
            })
        @unknown default:
            fatalError()
        }
    }
    
}
