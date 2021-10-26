//
//  ObservableType+.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/25.
//

import Foundation
import RxSwift

protocol Optionable {
    associatedtype Wrapped
    func flatMap<U>(_ transform: (Wrapped) throws -> U?) rethrows -> U?
    func map<U>(_ transform: (Wrapped) throws -> U) rethrows -> U?
}

extension Optional: Optionable {}

extension ObservableType where Element: Optionable {
    /**
    Takes a sequence of optional elements and returns a sequence of non-optional elements, filtering out any nil values.
    - returns: An observable sequence of non-optional elements
    */
    func unwrap() -> Observable<Element.Wrapped> {
        return self
            .filter { $0.map { $0 } != nil } // filter{ Type? != nil }
            .map { ($0.map { $0 })! } // map{ (Type?)! }
    }
}
