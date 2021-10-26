//
//  AttachmentInputPhotoStatus.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/25.
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
    
    let input: AnyObserver<Status>
    
    let output: Observable<Status>
    var status: Status {
        return self.statusSubject.value(Status.unSelected)
    }
    
    init() {
        self.input = self.statusSubject.asObserver()
        self.output = self.statusSubject.asObservable()
    }
    
}

class AttachmentInputPhotoSelectIndex {
    private let indexSubject = BehaviorSubject<Int>(value: 0)
    
    let input: AnyObserver<Int>
    
    let ouput: Observable<Int>
    var index: Int {
        return self.indexSubject.value(0)
    }
    
    init() {
        self.input = self.indexSubject.asObserver()
        self.ouput = self.indexSubject.asObservable()
    }
    
}
