//
//  VideoChatView.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/15.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class VideoChatView: XibView {
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var yourView: UIView!
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var footerView: UIView!
    
    // 상단 정보
    @IBOutlet weak var infoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var userMiniProfile: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userAge: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    
    @IBOutlet weak var pipMode: UIButton!
    @IBOutlet weak var camTurn: UIButton!
    
    // 상단 내 뷰, 리워드, 경과시간
    @IBOutlet weak var mineViewBtn: UIButton!
    @IBOutlet weak var rewardMiniView: UIView!
    @IBOutlet weak var timeRewardLabel: UILabel!
    @IBOutlet weak var rewardBtn: UIButton!
    @IBOutlet weak var durationTImer: UILabel!
    @IBOutlet weak var myViewCamNone: UIImageView!
    
    @IBOutlet weak var likeRankBtn: UIButton!
    @IBOutlet weak var rewardPopupView: UIView!
    @IBOutlet weak var rankPopupView: UIView!
    
    @IBOutlet weak var callDone: UIButton!
    @IBOutlet weak var sound: UIButton!
    @IBOutlet weak var like: UIButton!
    @IBOutlet weak var mic: UIButton!
    @IBOutlet weak var chat: UIButton!
    
    @IBOutlet weak var chatContainerView: UIView!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var constSpaceToFooterFromChatContainer: NSLayoutConstraint!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var chatSend: UIButton!
    
    var topHeight: CGFloat = 0
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingAct = UIActivityIndicatorView()
        loadingAct.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        loadingAct.center = mainView.center
        loadingAct.color = UIColor.white
        loadingAct.hidesWhenStopped = true
        loadingAct.style = UIActivityIndicatorView.Style.large
        
        loadingAct.startAnimating()
        return loadingAct
    }()
    
    let bag = DisposeBag()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isInitialized {
            initialize()
            self.addSubview(loadingIndicator)
            self.loadingIndicator.stopAnimating()
            isInitialized = false
            
        }
    }
    
    func initialize() {
        initView()
        bind()
    }
    
    func initView() {
        setView()
        addObserver()
    }
    
    func setView() {
        chatTextField.delegate = self
        
        if #available(iOS 13.0, *) {
            topHeight = self.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            if topHeight > 40 { infoTopConstraint.constant = 50 }
        }
        
        userMiniProfile.layer.borderColor = CGColor(red: 255/255, green: 81/255, blue: 129/255, alpha: 1)
        /*
         Female: CGColor(red: 255/255, green: 81/255, blue: 129/255, alpha: 1)
         Male: CGColor(red: 67/255, green: 130/255, blue: 255/255, alpha: 1)
        */
        
        
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

