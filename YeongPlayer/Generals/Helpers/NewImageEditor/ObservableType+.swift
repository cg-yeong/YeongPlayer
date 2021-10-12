//
//  ObservableType+.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/12.
//

import Foundation
import RxSwift

protocol Optionable {
    associatedtype Wrapped
    func flatMap<U>(_ transform: (Wrapped) throws -> U?) rethrows -> U?
    func map<U>(_ transform: (Wrapped) throws -> U) rethrows -> U?
}

extension Optional: Optionable {  }
extension ObservableType where Element: Optionable {
    
    /// 옵셔널 요소들을 nil을 필터링하고 논 - 옵셔널 요소로 변환한다
    /// return -  옵셔널 해제된 값들
    
    func unwrap() -> Observable<Element.Wrapped> {
        return self
            .filter { $0.map { $0 } != nil }    // filter { Type? != nil }
            .map { ($0.map { $0 })! }           // map { (Type?)! }
    }
    
}
