//
//  SettingViewModel.swift
//  YeongPlayer
//
//  Created by inforex on 2021/11/03.
//

import Foundation
import RxSwift
import RxCocoa

class SettingViewModel {
    let model = SettingModel()
    
    let bag = DisposeBag()
    
    var isSecretMode : Driver<Bool>
    
    init() {
        isSecretMode = model.isSecretMode
            .compactMap { $0 }
            .asDriver(onErrorRecover: { _ in .empty() })
            
    }
}
