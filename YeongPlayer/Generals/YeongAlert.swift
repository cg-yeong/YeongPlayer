//
//  YeongAlert.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/23.
//

import UIKit

class YeongAlert {
    
    static func baseAlert(message: String, rdoIt: (() -> Void)!) {
        let customAlert = UIAlertController(title: "주의!", message: message, preferredStyle: .alert)
        let leftAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let rightAction = UIAlertAction(title: "확인", style: .default) { act in
            rdoIt()
        }
        customAlert.addAction(leftAction)
        customAlert.addAction(rightAction)
        App.module.presenter.visibleViewController?.present(customAlert, animated: true, completion: nil)
    }
}
