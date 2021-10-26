//
//  VoiceRecordView.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/17.
//

import UIKit
import RxSwift
import Lottie
import AVFoundation
import Photos
import WebKit

class VoiceRecordView: XibView, WKNavigationDelegate {
    
    
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var recordIntputView: UIView!
    
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    @IBOutlet weak var userContentArea: UIView!
    
    @IBOutlet weak var chatContainerView: UIView!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var quitStack: UIStackView!
    @IBOutlet weak var quitChat: UIButton!
    @IBOutlet weak var reportQuitChat: UIButton!
    
    @IBOutlet weak var funcInputBtn: UIButton!
    @IBOutlet weak var inputBaseView: UIView!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var chatSendBtn: UIButton!
    @IBOutlet weak var reRecordBtn: UIButton!
    @IBOutlet weak var recordSendBtn: UIButton!
    @IBOutlet weak var recordingBtn: UIButton!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var txtInput: UITextField!
    
    @IBOutlet weak var pumpLottieView: UIView!
    @IBOutlet weak var progressBarView: UIView!
    
    var recordModel: RecordModel!
    var viewModel: RecordViewModel!
    
    var nowRecordState: recordState! = .ready
    var resultTime = 0
    
    var progressView: RecordProgressView! = nil
    var recon: RecordContainerView! = nil
    var waveLottie = AnimationView()
    var pumpLottie = AnimationView()
    
    var chatData = [MsgModel]()
    
    let bag = DisposeBag()
    
    // 녹음
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var recordTimer: Timer?
    var web: WKWebView!
    // 사진 - 
    var fetchResults: PHFetchResult<PHAsset>!
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    var alitems = [UIImage?]()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isInitialized {
            isInitialized = false
            
            setup()
            bind()
            
            
        }
        
    }
    func createWeb() {
        web = WKWebView(frame: CGRect(x: chatContainerView.bounds.minX,
                                                     y: chatContainerView.bounds.minY,
                                                     width: chatCollectionView.bounds.width, height: chatCollectionView.bounds.height))
        web.navigationDelegate = self
        self.chatContainerView.addSubview(web)
        
        let myURL = URL(string: "https://www.daum.net")
        let req = URLRequest(url: myURL!)
        web.load(req)
    }
    func setup() {
        setView()
        addObserver()
        txtInput.delegate = self
        viewModel = RecordViewModel(data: viewData)
        recordModel = viewModel.recordModel.value
        initProgressView()
        setRecordView(nowRecordState)
        
        //setFetchPhoto()

        
    }
    
    func setView() {
        buttonColor()
        recordingBtn.layer.cornerRadius = recordingBtn.frame.width / 2
        
        UIApplication.shared.isIdleTimerDisabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        
        setCollectionView()
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
    
    func initProgressView() {
        progressView = RecordProgressView()
        progressView.frame = progressBarView.bounds
        progressBarView.addSubview(progressView)
    }
    
    func initRecord() {
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
}

extension VoiceRecordView: UITextFieldDelegate {
    
}

extension VoiceRecordView: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // fetchData
        // setFetchPhoto()
    }
    
}
