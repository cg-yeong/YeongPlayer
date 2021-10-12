//
//  AttachmentInputPhotoStatus.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/12.
//

import Foundation
import RxSwift

class AttachmentInputPhotoStatus {
    
    enum Status {
        case unSelected
        case loading
        case downloading
        case compressing
        case selected
    }
    
    private let statusSubject = BehaviorSubject<Status>(value: .unSelected)
    
    // input
    let input: AnyObserver<Status>
    
    // output
    let ouput: Observable<Status>
    var status: Status {
        return (try? self.statusSubject.value()) ?? Status.unSelected
    }
    init() {
        self.input = self.statusSubject.asObserver()
        self.ouput = self.statusSubject.asObservable()
    }
    
}
