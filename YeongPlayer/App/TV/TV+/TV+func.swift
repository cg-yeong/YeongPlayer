//
//  TV+func.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/27.
//

import Foundation
import SwiftyJSON
import RxSwift
import RxCocoa

extension TV {
    
    @objc func detailTapped() {
        if chatInput.isEditing {
            chatDown()
        } else {
            
        }
    }
    
    func chatDown() {
        chatInput.endEditing(true)
    }
    
}
