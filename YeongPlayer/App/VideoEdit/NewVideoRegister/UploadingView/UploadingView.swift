//
//  RemoveVideoPopupView.swift
//

import UIKit
import SwiftyJSON
import RxCocoa
import RxSwift
import Lottie

class UploadingView : XibView{
    
    @IBOutlet weak var uploading_view: UIView!
    
    fileprivate var completionHandler : (() -> Void)?
    
    var disposbag = DisposeBag()
    
    
    let uploadAnimation = AnimationView()
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isInitialized {
            initialize()
            isInitialized = false
        }
    }
    
    func initialize(){
        rankBtnAnimation()
    }
    
    
    
    
    
    func rankBtnAnimation() {
        let animation = Animation.named("video_loding", subdirectory: "LottieImage")
                  
        uploadAnimation.animation = animation
        uploadAnimation.frame = uploading_view.bounds
        
        uploading_view.addSubview(uploadAnimation)

        uploadAnimation.play(fromProgress: 0, toProgress: 1, loopMode: .loop)
    }
}
