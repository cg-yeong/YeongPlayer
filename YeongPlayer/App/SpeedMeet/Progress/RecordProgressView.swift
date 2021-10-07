//
//  RecordProgressView.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/23.
//

import UIKit
import KDCircularProgress

class RecordProgressView: UIView {
    
    // 자신
    var view: UIView!
    var progress: KDCircularProgress!
    
    // 기본
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initView()
    }
    
    deinit {
        NSLog("deinit")
    }
    
    func initView() {
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        progress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 140, height: 140))
        progress.startAngle = 90
        progress.progressThickness = 0.12
        progress.trackThickness = 0.12
        progress.trackColor = UIColor(r: 245, g: 245, b: 245)
        progress.clockwise = true // true: 시계방향 false: 반시계방향
        progress.gradientRotateSpeed = 0.1
        progress.roundedCorners = false // 진행 트랙의 끝이 반원 반경인가?
        progress.glowMode = .forward
        progress.glowAmount = 0
        progress.angle = 1
        progress.set(colors: UIColor(r: 255, g: 105, b: 122, a: 1), UIColor(r: 255, g: 105, b: 122, a: 1))
        addSubview(progress)
    }
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "RecordProgressView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    
    func setProgress(_ Time: TimeInterval) {
        progress.animate(fromAngle: 0, toAngle: 360, duration: Time) { completed in
            if completed {
                log.d("animation Stopped, ocmpleted")
            } else {
                log.d("animation Stopped, was interrupted")
                log.d(Time)
            }
        }
    }
}
