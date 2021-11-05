//
//  BCItemListView.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/27.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON
// import AdvancedPageControl

class BCItemListView: XibView {
    
    @IBOutlet weak var another_view: UIView!
    @IBOutlet weak var page_scrollView: UIScrollView!
    @IBOutlet weak var page_view: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var jewelCount_label: UILabel!
    @IBOutlet weak var recharged_btn: UIButton!
    @IBOutlet weak var send_btn: UIButton!
    @IBOutlet weak var download_imageView: UIImageView!
    
    var data: JSON!
    var bag = DisposeBag()
//    var selectedItem:
//    var items:
//    var pages:
    var didRefresh: () -> Void = {}
//    var sendForTape:
    var jewelCount: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    var count = 4
    var isPageLast = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isInitialized {
            initialize()
            isInitialized = false
            animShow()
        }
    }
    
    func initialize() {
        
    }
    
    func animShow() {
        
    }
    
}
