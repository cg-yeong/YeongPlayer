//
//  VideoRecordViewController.swift
//  NextLevelDemo
//
//  Created by YuJongCheol on 2018. 12. 27..
//  Copyright © 2018년 YuJongCheol. All rights reserved.
//

import UIKit
import NextLevel
import AVFoundation
import AVKit
import Foundation
import Photos
import SwiftyJSON
import SwiftGifOrigin

import RxCocoa
import RxSwift

class NewVideoRecordViewController: UIViewController {
    
    //파악된
    /* ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ */
    @IBOutlet weak var complete_btn: UIButton!
    @IBOutlet weak var startRecord_Btn: UIButton!
    @IBOutlet weak var videoRemove_btn: UIButton!
    

    @IBOutlet weak var hiddenOnOff_view: UIView!
    @IBOutlet weak var close_btn: UIButton!
    
    @IBOutlet weak var flash_btn: UIButton!
    
    
    @IBOutlet weak var round_imageView: UIImageView!
    @IBOutlet weak var record_stauts_view: UIView!
    
    
    @IBOutlet weak var timerView: UIView!
    
    // 레코딩을 끊어서 하게될경우 각각의 프로그래스바 배열.
    var progressBarViews = [UIView]()
    let progressBar_color = UIColor(r: 255, g: 68, b: 114)
    
    let bag = DisposeBag()
    
    let nextLevel = NextLevel.shared
    
    // 외부에서 넘어올 데이타.
    var viewData = JSON()
    
    
    var recordListDS = [Int]()
    
    // 레코딩을 모니터링할 타이머.
    var recordTimer: Timer?
    
    var removeBarTimer: Timer?
    var removeBarTime = 0
    
    /* ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ */
    
    
    @IBOutlet weak var cameraPreview: UIView!
    
    @IBOutlet weak var progressContainerView: UIView!
    
    @IBOutlet weak var flipBtn: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 세션 스따뜨...
        DispatchQueue.main.async {
            self.nextLevel.automaticallyUpdatesDeviceOrientation = true
            self.nextLevel.focusMode = .autoFocus
            self.nextLevel.audioConfiguration.bitRate = 96000
            self.nextLevel.videoConfiguration.bitRate = 5500000
            self.nextLevel.videoConfiguration.preset = AVCaptureSession.Preset.high
            self.nextLevel.videoConfiguration.maxKeyFrameInterval = 30
            self.nextLevel.videoConfiguration.profileLevel = AVVideoProfileLevelH264HighAutoLevel
            self.nextLevel.deviceDelegate = self
            
            do {
                try self.nextLevel.start()
            } catch let error {
                print(error)
            }
            
            self.initializeVideoRecorder()
        }
        
        //백그라운드나 팝업뜨면 녹화 중지
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        setView()
        bind()
    }
    
    
    //파악된
    /* ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ */
    
    func setView(){
        // 타이머뷰 코너 라운드처리.
        timerView.layer.cornerRadius = self.timerView.bounds.height / 2
        timerView.clipsToBounds = true
        timerView.isHidden = true
        
        videoRemove_btn.isHidden = true
        complete_btn.isHidden = true
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func bind(){
        
        /*
         녹음 시작 버튼
         */
        startRecord_Btn.rx.tap
            .bind {
                self.startRecord_Btn.isUserInteractionEnabled = false
                self.startPause()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                    self.startRecord_Btn.isUserInteractionEnabled = true
                }
        }.disposed(by: bag)
        
        
        /*
         비디오 삭제 버튼
         */
        videoRemove_btn.rx.tap
            .bind {
                if !self.progressBarViews.isEmpty {
                    self.removeBarTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {(timer) in
                        self.removeBarTime += 1
                        if self.removeBarTime%2 == 0 {
                            self.progressBarViews.last!.backgroundColor = self.progressBar_color
                        }
                        else {
                            self.progressBarViews.last!.backgroundColor = UIColor(r: 174,g: 20,b: 62)
                        }
                    })
                }
                
                if !self.recordListDS.isEmpty {
                    App.module.presenter.addSubview(.visibleView, type: RemoveVideoPopupView.self){ view in
                        view.message = "방금 촬영한 초를 \"\(self.recordListDS.last!.toColonTime)\"삭제하시겠습니까?"
                        view.tag = 1010
                        
                        view.leftAction = {
                            self.progressBarViews.last!.backgroundColor = self.progressBar_color
                            self.clearBar()
                        }
                        
                        view.rightAction = {
                            self.removeLastClip()
                            self.clearBar()
                        }
                        
                        view.allAction = {
                            self.removeAllClips()
                            self.clearBar()
                        }
                    }
                }

        }.disposed(by: bag)
        
        
        /*
         비디오 저장 버튼
         */
        complete_btn.rx.tap
            .bind {
                self.completeEdit()
        }.disposed(by: bag)
        
        
        /*
         종료 버튼
         */
        close_btn.rx.tap
            .bind {
                if let session = self.nextLevel.session {
                    if CMTimeGetSeconds(session.totalDuration) > 0.0 {
                        CHAlert.CustomAlert(on: .visibleView, "촬영한 영상을 삭제하고 나가시겠습니까?", leftAction: AlertAction(title: "취소"), rightAction: AlertAction(title: "확인", action: {
                            self.close()
                        }))
                    }
                    else {
                        self.close()
                    }
                }
        }.disposed(by: bag)
    }
    
    
    
    
    
    
    func clearBar(){
        if removeBarTimer != nil {
            removeBarTimer?.invalidate()
            removeBarTimer = nil
        }
    }
    
    
    
    
    /*
     프로그레스바 생성
     */
    func makeNewProgressBar() {
        // 새로 만들어지는 바의 프레임을 계산한다.
        let previousTotalDuration = clippedTotalDuration()
        let maxSec = viewData["maxSec"].floatValue
        let posX = previousTotalDuration == 0 ? 0 : (previousTotalDuration * progressContainerView.bounds.width) / CGFloat(maxSec)
        let newBar = UIView(frame: CGRect(x: posX, y: 0, width: 0, height: progressContainerView.bounds.height))
        newBar.backgroundColor = self.progressBar_color
        self.progressContainerView.addSubview(newBar)
        
        // 저장.
        self.progressBarViews.append(newBar)
    }
    
    
    /*
     중간에 끊어서 녹음하는 부분 흰색으로
     */
    func stopCurrentProgressBar() {
        if let lastView = self.progressBarViews.last {
            let markView = UIView(frame: CGRect(x: lastView.bounds.width - 2, y: 0, width: 2, height: lastView.bounds.height))
            markView.backgroundColor = UIColor.white
            lastView.addSubview(markView)
        }
    }
    
    
    
    override func clearVC() {
        
        if recordTimer != nil {
            recordTimer?.invalidate()
            recordTimer = nil
        }
        nextLevel.pause()
        nextLevel.session?.removeAllClips(removeFiles: true)
        nextLevel.stop()
    }
    
    func close(){
        clearVC()
        clearBar()
        NotificationCenter.default.removeObserver(self)
        UIApplication.shared.isIdleTimerDisabled = false
        self.dismiss(animated: true, completion: nil)
    }
    
    /* ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ */


    func initializeVideoRecorder() {
        self.view.layoutIfNeeded()
        
        nextLevel.previewLayer.frame = cameraPreview.bounds
        cameraPreview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cameraPreview.layer.addSublayer(nextLevel.previewLayer)

        // 기존에 레코딩했던 파일 삭제.
        if let session = nextLevel.session {
            if let url = session.url {
                removeFileAtURLIfExists(url: url)
            }
        }
    }
    
    // 클립이 하나라도 있냐 없냐에 다라서 버튼보여주는 것이 다르다.
    func checkTotalDuration() {
        // 기본세팅.
        
        timerLabel.text = "00:00"
        nextLevel.automaticallyUpdatesDeviceOrientation = true
        
        // 클립이 하나라도 있으면.
        if let session = nextLevel.session {
            if CMTimeGetSeconds(session.totalDuration) > 0.0 {
                videoRemove_btn.isHidden = false
                complete_btn.isHidden = false
                nextLevel.automaticallyUpdatesDeviceOrientation = false
                
                let totalDuration = CMTimeGetSeconds(session.totalDuration)
                timerLabel.text = String(format: "%02d:%02d", Int(totalDuration) / 60, Int(totalDuration) % 60)
            } else {
                //  클립하나라도 없으면 삭제
                videoRemove_btn.isHidden = true
                complete_btn.isHidden = true
                // 현재 오리엔테이션으로 변경되도록 노티를 쏴준다.
                NotificationCenter.default.post(name: UIDevice.orientationDidChangeNotification, object: nil)
            }
            
            
            
            if viewData["minSec"].intValue <= Int(CMTimeGetSeconds(session.totalDuration)) {
                complete_btn.setImage(UIImage(named: "btnCompletion"), for: .normal)
            }
            else {
                complete_btn.setImage(UIImage(named: "btnCompletionDisable"), for: .normal)
            }
        }

    }

    @IBAction func toggleTorch() {
        // 후면카메라인경우는 토글시킨후 상황에 맞게 버튼이미지를 변경한다
        if nextLevel.devicePosition == .back {
            if nextLevel.isTorchAvailable {
                if nextLevel.torchMode == .on {
                    nextLevel.torchMode = .off
                    flash_btn.setImage(UIImage(named: "icoFlashOff"), for: .normal)
                } else {
                    nextLevel.torchMode = .on
                    flash_btn.setImage(UIImage(named: "icoFlashOn"), for: .normal)
                }
            // 전면카메라상황에서 함수가 호출되는 경우다.
            } else {
                flash_btn.setImage(UIImage(named: "icoFlashOff"), for: .normal)
            }
        // 전면인경우는 버튼이미지를 고정으로 변경한다.
        } else {
            nextLevel.torchMode = .off
            flash_btn.setImage(UIImage(named: "icoFlashOff"), for: .normal)
        }
    }
    
    
    @IBAction func flipCamera(_ sender: UIButton) {
        nextLevel.flipCaptureDevicePosition()
        toggleTorch()
    }

    func completeEdit(){
        if let session = nextLevel.session {
            if Float(CMTimeGetSeconds(session.totalDuration)) < viewData["minSec"].floatValue {
                Toast.show("\(viewData["minSec"].intValue)초 이상 촬영해주세요.",on: .visibleView, duration: 3.0)
            }
            else {
                LoadingIndicator.show()
                session.mergeClips(usingPreset: AVAssetExportPresetHighestQuality, completionHandler: { (url, error) in
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: {
                            self.clearVC()
                                guard let vc = UIStoryboard(name: "NewVideoRegister", bundle: nil).instantiateViewController(withIdentifier: "NewvideoEditor") as? NewVideoEditorController else {
                                    return
                                }
                                vc.isPhotoRecord = true
                                vc.videoURL = url
                                vc.bridgeData = self.viewData
                                getVisibleViewController().present(vc, animated: true, completion: nil)
                            LoadingIndicator.hide()
                            
                        })
                    }
                })
            }
        }
    }
    
    func startPause() {
        // 레코딩 토글
        if nextLevel.isRecording {
            nextLevel.pause()
        } else {
            if let session = NextLevel.shared.session {
                if CGFloat(CMTimeGetSeconds(session.totalDuration)) < CGFloat(viewData["maxSec"].floatValue) {
                    nextLevel.record()
                }
                else {
                    Toast.show("최대 \(viewData["maxSec"].intValue.toTime)까지 촬영 가능합니다.",on: .visibleView, duration: 3.0)
                }
            }
        }
        
        // 일단 회전 잠가주고..
        nextLevel.automaticallyUpdatesDeviceOrientation = false

        // 일단 타이머 작살내고.
        self.recordTimer?.invalidate()
        self.recordTimer = nil
        
        // 레코딩여부에 따라서 타이머 출발 및 뷰레이아웃 조정.
        if nextLevel.isRecording {
            
            complete_btn.isHidden = true
            videoRemove_btn.isHidden = true

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
                        
                self.round_imageView.transform = CGAffineTransform.init(scaleX: 1.4, y: 1.4)
    
                    UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
                        self.round_imageView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    }) { (flag) in
                    }
                }) { (flag) in
            }
        
            
            
            //녹음 타임
            recordTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(recordMonitor), userInfo: nil, repeats: true)
            
            // 컨트롤 구성요소 뷰 안보이게.
            hiddenOnOff_view.isHidden = true
            
            //타임뷰 보이고
            timerView.isHidden = false
            
            
            // 버튼백그라운드 이미지 변경하고.  링이미지 보이게하고
            startRecord_Btn.setImage(UIImage(named: "btnPause"), for: .normal)
            // 링이미지 보이게하고
            round_imageView.image = UIImage(named: "imgRecordingActOn")
            

            //녹음색 변경
            record_stauts_view.backgroundColor = UIColor(r: 255, g: 42, b: 42)
            // 새로운 프로그래스바 생성.
            makeNewProgressBar()

        } else {
            if let session = nextLevel.session {
                let currentClipDuration = CMTimeGetSeconds(session.currentClipDuration)
                if currentClipDuration == 0.0 {
                    return
                }
                self.recordListDS.append(Int(CMTimeGetSeconds(session.currentClipDuration)))
            }
            
            self.round_imageView.layer.removeAllAnimations()
            
            hiddenOnOff_view.isHidden = false
            
            startRecord_Btn.setImage(UIImage(named: "btnRecording"), for: .normal)
            round_imageView.image = UIImage(named: "imgRecordingActOff")
            
            record_stauts_view.isHidden = false
            record_stauts_view.backgroundColor = UIColor(r: 194, g: 194, b: 194)
            
            checkTotalDuration()
            
            // 마지막 프로그래스바 마무리.
            stopCurrentProgressBar()
            
            if let session = nextLevel.session {
                if Float(CMTimeGetSeconds(session.totalDuration)) < viewData["minSec"].floatValue {
                    Toast.show("\(viewData["minSec"].intValue)초 이상 촬영해주세요.",on: .visibleView, duration: 3.0)
                }
            }
        }
    }

    func clippedTotalDuration() -> CGFloat {
        var duration:CGFloat = 0.0
        if let session = nextLevel.session {
            for clip in session.clips {
                duration += CGFloat(CMTimeGetSeconds(clip.duration))
            }
        }
        return duration
    }
    
    @objc func recordMonitor() {
        let maxSec = viewData["maxSec"].floatValue
        if let session = nextLevel.session {
            let totalDuration = CMTimeGetSeconds(session.totalDuration)
            
            if CGFloat(totalDuration) >= CGFloat(maxSec) {
                self.startPause()
                return
            }
            
            if viewData["minSec"].intValue <= Int(totalDuration) {
                complete_btn.setImage(UIImage(named: "btnCompletion"), for: .normal)
            }
            else {
                complete_btn.setImage(UIImage(named: "btnCompletionDisable"), for: .normal)
            }
            
            // 타이머 레이블 수정해주고...
            self.timerLabel.text = String(format: "%02d:%02d", Int(totalDuration) / 60, Int(totalDuration) % 60)
            
            self.record_stauts_view.isHidden = Int(totalDuration * 10) % 10 > 4 ? false : true
            
            // 프로그래스바 늘려주고.
            DispatchQueue.main.async {
                if let currentBar = self.progressBarViews.last {
                    if let session = self.nextLevel.session {
                        let currentClipDuration = CGFloat(CMTimeGetSeconds(session.currentClipDuration))
                        let newWidth = (currentClipDuration * self.progressContainerView.bounds.width) / CGFloat(maxSec)
                        let newFrame = CGRect(origin: currentBar.frame.origin, size: CGSize(width: newWidth, height: currentBar.bounds.height))
                        currentBar.frame = newFrame
                    }
                }
            }
        }
    }
    
    @objc func appMovedToBackground() {
        // 레코딩중이면 멈춰라.
        if nextLevel.isRecording {
            startPause()
        }
    }
    
    func removeLastClip() {
        // 클립지우고.
        if let session = nextLevel.session {
            session.remove(clipAt: session.clips.count - 1, removeFile: true) // not use session.removeLastClip()
        }
        
        // 프로그래스바도 지우고
        if let lastView = self.progressBarViews.last {
            lastView.removeFromSuperview()
            self.progressBarViews.remove(at: self.progressBarViews.count - 1)
        }
        
        self.recordListDS.remove(at: self.recordListDS.count - 1)

        // 남은시간 체크해서 조정할것 조정하고.
        self.checkTotalDuration()
    }
    func removeAllClips() {
        while recordListDS.count > 0 {
            removeLastClip()
        }
    }
}

extension NewVideoRecordViewController: NextLevelDeviceDelegate {
    func nextLevelDevicePositionWillChange(_ nextLevel: NextLevel) {
        
    }
    
    func nextLevelDevicePositionDidChange(_ nextLevel: NextLevel) {
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didChangeDeviceOrientation deviceOrientation: NextLevelDeviceOrientation) {
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didChangeDeviceFormat deviceFormat: AVCaptureDevice.Format) {
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didChangeCleanAperture cleanAperture: CGRect) {
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didChangeLensPosition lensPosition: Float) {
        
    }
    
    func nextLevelWillStartFocus(_ nextLevel: NextLevel) {
        
    }
    
    func nextLevelDidStopFocus(_ nextLevel: NextLevel) {
        
    }
    
    func nextLevelWillChangeExposure(_ nextLevel: NextLevel) {
        
    }
    
    func nextLevelDidChangeExposure(_ nextLevel: NextLevel) {
        
    }
    
    func nextLevelWillChangeWhiteBalance(_ nextLevel: NextLevel) {
        
    }
    
    func nextLevelDidChangeWhiteBalance(_ nextLevel: NextLevel) {
        
    }
}
