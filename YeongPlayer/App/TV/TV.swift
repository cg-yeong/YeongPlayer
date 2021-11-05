//
//  TV.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/27.
//

import UIKit
import RxSwift
import RxCocoa


class TV: XibView {
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var yourView: UIView!
    @IBOutlet weak var detailView: UIView!
    
    @IBOutlet var floating_view: UIView!
    @IBOutlet weak var floating_camera_view: UIView!
    @IBOutlet weak var floating_stop_imageView: UIImageView!
    @IBOutlet weak var floating_change_btn: UIButton!
    @IBOutlet weak var floating_exit_btn: UIButton!
    
    @IBOutlet weak var chatContainerView: UIView!
    // ***
    @IBOutlet weak var constSpaceFromChatContainerView: NSLayoutConstraint!
    @IBOutlet weak var chatInput: UITextField!
    @IBOutlet weak var input_view: UIView!
    @IBOutlet weak var giftBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var chatSendBtn: UIButton!
    @IBOutlet weak var newBadge: UIImageView!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    
    @IBOutlet weak var gift_view: UIView!
    // ***
    @IBOutlet weak var gift_constraint_bottom: NSLayoutConstraint!
    @IBOutlet weak var info_view: UIView!
    @IBOutlet weak var mini_profile_view: UIView!
    
    @IBOutlet weak var floatingToggleBtn: UIButton!
    @IBOutlet weak var exitLiveBtn: UIButton!
    
    // 단순 플로팅 모드 구분 플래그
    var isFloatingMode = false
    
    // 방송 SDK 플로팅 모드 판별 플래그 -> Publisher, Subscriber
    var isChangeView = false
    var isRemoteAble = true
    
    lazy var videoView_pan: UIPanGestureRecognizer = {
        let view = UIPanGestureRecognizer()
        return view
    }()
    
    var bag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isInitialized {
            
            initialize()
            
            
            isInitialized = false
        }
    }
    
    func initialize() {
        
        setView()
        addObserver()
        
        // 권한체크
        permissionCheck()
        
        bind()
    }
    
    func setView() {
        
        videoView_pan.isEnabled = false
    }
    
    
    func permissionCheck() {
        Permission.sharedInstance.request(.Camera, completeHandler: { allow in
            if !allow {
                Permission.sharedInstance.manualyAuthorization(.Camera)
                self.microphoneCheck()
            } else {
                self.microphoneCheck()
            }
        })
    }
    func microphoneCheck() {
        Permission.sharedInstance.request(.Microphone, completeHandler: { allow in
            if !allow {
                Permission.sharedInstance.manualyAuthorization(.Microphone)
            } else {
                DispatchQueue.main.async {
                    
                }
            }
        })
    }
    
    // MARK: 플로팅모드
    /* 플로팅 모드로 전환 */
    @objc func toggleFloating() {
        isFloatingMode = !isFloatingMode
        if isFloatingMode {
            
            loadingSubView(subView: floating_camera_view, onCompletion: nil)
            
            
            
        } else {
            
            loadingSubView(subView: mainView, onCompletion: nil)
            
        }
    }
    /* 뷰 체인지 플로팅 / 메인뷰 */
    func loadingSubView(subView: UIView, onCompletion: (() -> Void)?) {
        // 메인 뷰는 히든 처리하고 플로팅 뷰를 addSubView <-> removeFromSuperView 처리
        if isFloatingMode {
            
            frame = CGRect(x: 50, y: 50, width: floating_view.frame.width, height: floating_view.frame.height)
            mainView.isHidden = true
            videoView_pan.isEnabled = true
            addSubview(floating_view)
            
        } else {
            
            floating_view.removeFromSuperview()
            frame = UIScreen.main.bounds
            mainView.isHidden = false
            videoView_pan.isEnabled = false
//            isFloatingMode = false
            
        }
    }
    
    /* 플로팅 화면 범위 드래그 이동 */
    @objc func viewViewPanning(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        
        // 상태바 넘으면 안되니까 상태바 frame 구하기
        var statusFrame: CGRect {
            if #available(iOS 13.0, *) {
                return self.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
            } else {
                return UIApplication.shared.statusBarFrame
            }
        }
        let screen = App.module.presenter.visibleViewController
        if let view = screen?.view {
            if let senderView = recognizer.view {
                
                // 화면이 왼쪽으로 넘어갈 때
                if senderView.frame.origin.x < 0.0 {
                    senderView.frame.origin = CGPoint(x: 0.0, y: senderView.frame.origin.y)
                }
                
                // 화면이 상태바 위쪽으로 넘어갈 때
                if senderView.frame.origin.y < statusFrame.height {
                    senderView.frame.origin = CGPoint(x: senderView.frame.origin.x, y: statusFrame.height)
                }
                
                // 화면이 오른쪽으로 넘어갈 때 (플로팅화면 시작점 + 너비 > 기기 화면 너비)
                if senderView.frame.origin.x + senderView.frame.size.width > view.frame.width {
                    senderView.frame.origin = CGPoint(x: view.frame.width - senderView.frame.size.width, y: senderView.frame.origin.y)
                }
                
                // 화면이 아래쪽으로 넘어갈 때 (플로팅화면 시작점 + 높이 > 기기 화면 높이)
                if senderView.frame.origin.y + senderView.frame.size.height > view.frame.height {
                    senderView.frame.origin = CGPoint(x: senderView.frame.origin.x, y: view.frame.height - senderView.frame.size.height)
                }
            }
        }
        
        if let centerX = recognizer.view?.center.x, let centerY = recognizer.view?.center.y {
            recognizer.view?.center = CGPoint(x: centerX + translation.x, y: centerY + translation.y)
            recognizer.setTranslation(.zero, in: self)
        }
        
        
    }
}
