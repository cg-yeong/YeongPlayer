//
//  GalleryPopupView.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/12.
//

import UIKit
import RxSwift
import SwiftyJSON
import RxCocoa

class GalleryPopupView: XibView {
    @IBOutlet weak var another_view: UIView!
    @IBOutlet weak var photo_btn: UIButton!
    @IBOutlet weak var video_btn: UIButton!
    
    var openType: ((Gallerytype) -> Void)?
    
    let bag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isInitialized {
            initialize()
            isInitialized = false
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
    }
    
    func initialize() {
        setLayout()
        setView()
        bind()
    }
    func setLayout() {
        
    }
    func setView() {
        
    }
    
    func bind() {
        let without = UITapGestureRecognizer()
        another_view.addGestureRecognizer(without)
        
        without.rx.event
            .throttle(1, scheduler: MainScheduler.instance)
            .bind {_ in
                self.openType!(.none)
                self.removeFromSuperview()
            }.disposed(by: bag)
        
        photo_btn.rx.tap
            .bind { _ in
                self.openType!(.photo)
                self.removeFromSuperview()
            }.disposed(by: bag)
        
        video_btn.rx.tap
            .bind { _ in
                self.openType!(.video)
                self.removeFromSuperview()
            }.disposed(by: bag)
        
    }
    
}
