//
//  BehaviorSubject+.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/25.
//

import Foundation
import RxSwift

extension BehaviorSubject {
    func value(_ defaultValue: Element) -> Element {
        return (try? self.value()) ?? defaultValue
    }
}
