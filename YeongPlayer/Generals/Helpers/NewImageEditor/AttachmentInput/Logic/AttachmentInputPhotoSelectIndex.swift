//
//  AttachmentInputPhotoSelectIndex.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/12.
//

import Foundation
import RxSwift

class AttachmentInputPhotoSelectIndex {
    private let indexSubject = BehaviorSubject<Int>(value: 0)
    
    // input
    let input: AnyObserver<Int>
    
    // output
    let output: Observable<Int>
    var index: Int {
        return (try? self.indexSubject.value()) ?? 0
    }
    
    init() {
        self.input = self.indexSubject.asObserver()
        self.output = self.indexSubject.asObservable()
    }
    
    
}
