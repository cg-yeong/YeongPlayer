//
//  RecordModel.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/17.
//

import Foundation
import SwiftyJSON

enum recordState {
    case ready
    case recordStart
    case recordStop
    case playStart
    case playStop
}


class RecordModel {
    
    var memNo = ""
    var uploadPath = ""
    var minSec = "1"
    var maxSec = "600"
    var funcName = ""
    
    init() {
        setData()
    }
    
    func setData() {
        minSec = "1"
        maxSec = "600"
    }
}
