//
//  RecordContainerView.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/27.
//

import UIKit
import RxSwift


class RecordContainerView: XibView {
    
    @IBOutlet weak var reRecordBtn: UIButton!
    @IBOutlet weak var recordSendBtn: UIButton!
    @IBOutlet weak var recordingBtn: UIButton!
    override func layoutSubviews() {
        super.layoutSubviews()
        if isInitialized {
            buttonColor()
            animateUp()
            isInitialized = false
            
        }
        
    }
    override func removeFromSuperview() {
        animateDown { _ in
            super.removeFromSuperview()
        }
    }
    func buttonColor() {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.cornerRadius = CGFloat(recordingBtn.frame.width / 2)
        gradient.frame = recordingBtn.bounds
        gradient.colors = [
            UIColor(r: 255, g: 121, b: 116).cgColor,
            UIColor(r: 255, g: 55, b: 142).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.locations = [0.2, 1]
        recordingBtn.layer.insertSublayer(gradient, at: 0)
        
        let gradient2: CAGradientLayer = CAGradientLayer()
        gradient2.cornerRadius = CGFloat(17.0)
        gradient2.frame = recordSendBtn.bounds
        gradient2.colors = [
            UIColor(r: 255, g: 121, b: 116).cgColor,
            UIColor(r: 255, g: 55, b: 142).cgColor
        ]
        gradient2.startPoint = CGPoint(x: 0, y: 0.5)
        gradient2.endPoint = CGPoint(x: 1, y: 0.5)
        gradient2.locations = [0.2, 1]
        recordSendBtn.layer.insertSublayer(gradient2, at: 0)
    }
}
