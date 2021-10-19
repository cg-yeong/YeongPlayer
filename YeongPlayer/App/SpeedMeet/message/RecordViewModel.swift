//
//  RecordViewModel.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/17.
//

import Foundation
import SwiftyJSON
import RxCocoa
import RxSwift
import AVFoundation

protocol RecordControlDelegate {
    func printProgressTime(_ seconds: Double, _ type: Bool) -> String
}

class RecordViewModel {
    let bag = DisposeBag()
    let recordModel: BehaviorRelay<RecordModel>
    var recordControlDelegate: RecordControlDelegate!
    
    var temp = ""
    
    init(data: JSON) {

        recordModel = BehaviorRelay<RecordModel>(value: RecordModel())
        recordControlDelegate = self
        
    }
    
}

extension RecordViewModel: RecordControlDelegate {
    func printProgressTime(_ seconds: Double, _ type: Bool) -> String {
        if type {
            return Int(floor(seconds)).toTime
        } else {
            return Int(floor(seconds)).toColonTime
        }
    }
}

