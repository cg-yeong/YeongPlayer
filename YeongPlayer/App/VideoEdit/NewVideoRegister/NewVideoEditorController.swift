//
//  VideoEditor.swift
//  VideoEdit
//
//  Created by YuJongCheol on 2018. 3. 9..
//  Copyright © 2018년 INFOREX. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import Photos
import AVKit

import RxCocoa
import RxSwift
import Lottie

class NewVideoEditorController: UIViewController, NewABVideoRangeSliderDelegate {
    @IBOutlet weak var close_btn: UIButton!
    @IBOutlet weak var next_btn: UIButton!
    @IBOutlet weak var videoTime_label: UILabel!
    
    @IBOutlet weak var cover_btn: UIButton!
    @IBOutlet weak var edit_btn: UIButton!
    
    
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var videoContainer: UIView!
    @IBOutlet weak var rangeSlider: NewABVideoRangeSlider!
    
    @IBOutlet weak var slider_view: UIView!
    
    @IBOutlet weak var thumbnail_modal_view: UIView!
    @IBOutlet weak var thumbnail_player_view: UIView!
    @IBOutlet weak var thumbnail_view: UIView!
    
    var videoURL : URL!
    var isPhotoRecord = false
    var isCover = false
    
    var cutTime = 0.0
    
    var percentage : CGFloat = 0
    
    var avPlayer: AVPlayer! = nil
    var avPlayerLayer: AVPlayerLayer! = nil
    
    var thumbnailLayer: AVPlayerLayer! = nil
    
    var timeObserver: AnyObject!
    var startTime = 0.0;
    var endTime = 0.0;
    var progressTime = 0.0;
    var shouldUpdateProgressIndicator = true
    var isSeeking = false
    
    var duration: Float64   = 0.0
    
    var bridgeData: JSON!

    var exportSession: AVAssetExportSession!
    
    var progressPercentage: CGFloat = 0         // Represented in percentage
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readyMovie()
        setView()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avPlayerLayer.frame = videoContainer.bounds
    }
    
    func setView(){
        let coverDrag = UIPanGestureRecognizer(target:self, action: #selector(coverDragged(_:)))
        thumbnail_view.isUserInteractionEnabled = true
        thumbnail_view.addGestureRecognizer(coverDrag)
        
        let coverModalTap = UIPanGestureRecognizer(target:self, action: #selector(coverDragged(_:)))
        thumbnail_modal_view.isUserInteractionEnabled = true
        thumbnail_modal_view.addGestureRecognizer(coverModalTap)
        
        cutTime = CMTimeGetSeconds((self.avPlayer.currentItem?.duration)!)
    }
    
    func bind(){
        next_btn.rx.tap
            .bind {
                self.done()
        }.disposed(by: bag)
        
        close_btn.rx.tap
            .bind {
                self.clearVC()
                self.dismiss(animated: true, completion: nil)
        }.disposed(by: bag)
        
        cover_btn.rx.tap
            .bind {
                self.isCover = true
                self.coverSelect()
        }.disposed(by: bag)
        
        edit_btn.rx.tap
            .bind {
                self.isCover = false
                self.cutSelect()
        }.disposed(by: bag)
        
        btnPlay.rx.tap
            .bind {
                if self.isCover {        //커버선택할때는 재생 불가능
                    return
                }
                
                self.avPlayer.play()
                self.shouldUpdateProgressIndicator = true
                self.btnPlay.isHidden = true
        }.disposed(by: bag)
    }
    
    func readyMovie() {
        if self.avPlayer == nil {
            self.avPlayer = AVPlayer()
        }
        let playerItem = AVPlayerItem(url: videoURL)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = videoContainer.bounds
        avPlayerLayer.videoGravity = .resizeAspect
        videoContainer.layer.insertSublayer(avPlayerLayer, at: 0)
        videoContainer.layer.masksToBounds = true
        
        
        
        thumbnailLayer = AVPlayerLayer(player: avPlayer)
        thumbnailLayer.frame = thumbnail_player_view.bounds
        thumbnailLayer.videoGravity = .resizeAspectFill
        thumbnail_player_view.layer.insertSublayer(thumbnailLayer, at: 0)
        thumbnail_player_view.layer.masksToBounds = true
        
        rangeSlider.setMyVideoURL(videoURL: videoURL)
        rangeSlider.delegate = self
        /*
        rangeSlider.startIndicator.isHidden = true
        rangeSlider.endIndicator.isHidden = true
        rangeSlider.topLine.isHidden = true
        rangeSlider.bottomLine.isHidden = true
        */
        rangeSlider.startTimeView.isHidden = true
        rangeSlider.endTimeView.isHidden = true
        
        
        // 비됴 준비되었는지 모니터링시작하고...
        avPlayer.currentItem?.addObserver(self, forKeyPath: "status", options: [NSKeyValueObservingOptions.initial, NSKeyValueObservingOptions.new], context: nil)
        
    }
    
    
    // 비됴가 사용할 준비가 되었는지 체크한다.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if self.avPlayer.currentItem?.status == AVPlayerItem.Status.readyToPlay {
            DispatchQueue.main.async {
                // 요땅...
                let totalDuration = CMTimeGetSeconds((self.avPlayer.currentItem?.duration)!)
                if totalDuration.isNaN { return }
                
                // 옵저벼 지우고.
                self.avPlayer.currentItem?.removeObserver(self, forKeyPath: "status")
                
                
                let timeInterval: CMTime = CMTimeMakeWithSeconds(0.1, preferredTimescale: 100)
                self.timeObserver = self.avPlayer.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { (elapsedTime) in self.observeTime(elapsedTime: elapsedTime)}) as AnyObject
                
                // 슬라이더 옵션 몇개 더 주고.
                self.rangeSlider.maxSpace = self.bridgeData["maxSec"].floatValue
                self.rangeSlider.minSpace = self.bridgeData["minSec"].floatValue
                
                // 선택박스 조정해주고.
                let maxSec = self.bridgeData["maxSec"].doubleValue
                if totalDuration > maxSec {
                    self.rangeSlider.setEndPosition(seconds: Float(maxSec))
                    self.endTime = Double(maxSec)
                } else {
                    self.endTime = totalDuration
                }
                
                self.videoTime_label.text = Int(self.endTime).toColonTime
                
                // 플레이버튼 보이게 하고.
                self.btnPlay.isHidden = false
                
                // 제스쳐 등록하고.
                self.videoContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.pauseTapped)))
                
                self.avPlayer.play()
                self.shouldUpdateProgressIndicator = true
                self.btnPlay.isHidden = true
            }
        }
    }

    @objc func pauseTapped() {
        
        if isCover {
            return
        }
        
        avPlayer.pause()
        btnPlay.isHidden = false
    }
    

    override func clearVC() {
        // 정리하고 닫자.
        self.avPlayer.pause()
        DispatchQueue.main.async {
            self.timeObserver?.invalidate()
            self.avPlayer.replaceCurrentItem(with: nil)
            if self.videoContainer.layer.sublayers != nil {
                for layer in self.videoContainer.layer.sublayers! {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
    
    func goClose(destURL: URL?, duration: Int?, filesize: Int?) {
        self.avPlayer.pause()
        DispatchQueue.main.async {
            
             
            
            //웹에다가 전송할 데이터
            let imgGenerator = AVAssetImageGenerator(asset: AVAsset(url: self.videoURL))
            imgGenerator.appliesPreferredTrackTransform = true
            let time = CMTimeMakeWithSeconds(self.progressTime, preferredTimescale: 1000)
            
            imgGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)], completionHandler: { (requestedTime, thumbnail, actualTime, result, error) in
                
                // 저장할 이름을 정한다.
                var imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                imageURL!.appendPathComponent("clubIosImageFile.jpg")

                // 이미 같은이름으로 있으면 지운다.
                removeFileAtURLIfExists(url: imageURL!)

                let thumbnailTime = Int(CMTimeGetSeconds(self.avPlayer.currentTime()))
                let thumbnailImage = self.avPlayer.generateThumbnail(time: self.avPlayer.currentTime())
                let imageData = thumbnailImage?.jpegData(compressionQuality: 1.0)
                
                
                // 저장한다.
                if let data = thumbnailImage?.jpegData(compressionQuality: 1.0) {
                    do {
                        try data.write(to: imageURL!)
                    } catch let error {
                        print(error)
                    }
                }
                
                self.bridgeData["videoFilename"] = JSON(destURL!.path)
                
                // 이미지를 base64 인코딩 스트링으로 변환
                var videoData: Data!
                do {
                    videoData = try Data(contentsOf: destURL!)
                } catch let error {
                    print(error)
                    return
                }

                
                //포토서버에 업로드 해준다
                
                    if self.isPhotoRecord {
                        
                        var maxCount = 0
                        var lastIndex = 1
                        
                        
                        //디바이스에 저장
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destURL!)
                        }) { saved, error in
                            if saved {
                            }
                        }
                        
                        
                        //앨범에서 선택한것들 업로드해주고
                        DispatchQueue.main.async {
                            if let photoView = getVisibleViewController() as? PhotoViewController {
                                lastIndex = photoView.viewModel.dataListValue.count
                                maxCount = lastIndex + 1
                                
                                if photoView.viewModel.dataListValue.isEmpty {
                                    lastIndex = 1
                                }
                                photoView.uploadMuti({
                                    //방금 찍은거 업로드
                                    MediaUploadManager.uploadMuti(data: self.bridgeData,
                                                                  imageData: imageData!,
                                                                  videoData: videoData,
                                                                  fileSlct: "v",
                                                                  fileCurIdx: lastIndex,
                                                                  fileMaxCount: maxCount,
                                                                  captureTime: thumbnailTime, {
                                                                    
                                            //임시파일 지우고
                                            removeFileAtURLIfExists(url: imageURL!)
                                            removeFileAtURLIfExists(url: destURL!)
                                                                    
                                            //편집 뷰 닫고
                                            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                                            //앨범 열려있으면 닫고
                                            if let photoView = getVisibleViewController() as? PhotoViewController {
                                                photoView.dismiss(animated: true, completion: nil)
                                            }
                                    })
                                })
                                log.d("2")
                            }
                            else {  //카메라 열어서 바로 업로드
                                log.d("3")
                                MediaUploadManager.uploadMuti(data: self.bridgeData, imageData: imageData!, videoData: videoData, fileSlct:  "v", captureTime: thumbnailTime, {
                                    self.dismiss(animated: true, completion: nil)
                                })
                            }
                        }

                    }
                    else{
                        log.d("1")
                        MediaUploadManager.uploadMuti(data: self.bridgeData, imageData: imageData!, videoData: videoData, fileSlct:  "v", captureTime: thumbnailTime, {
                            self.dismiss(animated: true, completion: nil)
                            
                            //앨범 열려있으면 닫고
                            if let photoView = getVisibleViewController() as? PhotoViewController {
                                photoView.dismiss(animated: true, completion: nil)
                            }
                        })
                    }
                self.clearVC()
            })
        }
    }
    
    func done() {
        App.module.presenter.addSubview(.visibleView, type: UploadingView.self){ view in
        }
        
        // 일단 멈추고.
        pauseTapped()
        // 트림 비됴.
        goTrimVideo()
    }
    
    func goTrimVideo() {
        let timeScale : Int32 = 600
        
        var destURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        destURL!.appendPathComponent("clubIosVideoFile.mp4")
        

        // 생성.
        let trimPoint = (CMTimeMakeWithSeconds(startTime, preferredTimescale: timeScale), CMTimeMakeWithSeconds(endTime, preferredTimescale: timeScale))
        
        trimVideo(sourceURL: videoURL, destinationURL: destURL!, trimPoint: trimPoint, completion: { error in
            let videoDuration = Int(self.endTime - self.startTime)
            var videoSize = 0
            
            // 파일사이즈 구하기.
            let contents = try? FileManager.default.attributesOfItem(atPath: destURL!.path)
            if let attr = contents {
                if let filesize = attr[FileAttributeKey.size] {
                    videoSize = filesize as! Int
                }
            }

            self.goClose(destURL: destURL, duration: videoDuration, filesize: videoSize)
        })
    }
    
    private func observeTime(elapsedTime: CMTime) {
        let elapsedTime = CMTimeGetSeconds(elapsedTime)

        if (avPlayer.currentTime().seconds >= self.endTime){
            self.pauseTapped()
            self.initializeProgressBar(position: self.startTime)
        }
        
        if self.shouldUpdateProgressIndicator {
            rangeSlider.updateProgressIndicator(seconds: elapsedTime)
        }
    }
    
    // ABVideoRangeSlider delegate
    func indicatorDidChangePosition(videoRangeSlider: NewABVideoRangeSlider, position: Float64) {
        self.shouldUpdateProgressIndicator = false
        
        self.pauseTapped()
        
        if self.progressTime != position {
            self.initializeProgressBar(position: position)
        }
    }
    
    func didChangeValue(videoRangeSlider: NewABVideoRangeSlider, startTime: Float64, endTime: Float64) {
        
        self.endTime = endTime
        
        if startTime != self.startTime{
            self.startTime = startTime
            
            let timescale = self.avPlayer.currentItem?.asset.duration.timescale
            let time = CMTimeMakeWithSeconds(self.startTime, preferredTimescale: timescale!)
            if !self.isSeeking{
                self.isSeeking = true
                avPlayer.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { _ in
                    self.isSeeking = false
                })
            }
            
            
        }
        
        videoTime_label.text = Int(ceil(endTime - startTime)).toColonTime
    }
    
    func indicatorSliderChangeEnded() {
        avPlayer.play()
        shouldUpdateProgressIndicator = true
        btnPlay.isHidden = true
    }
    
    func initializeProgressBar(position: Float64) {
        //log.d(position)
        let timescale = self.avPlayer.currentItem?.asset.duration.timescale
        let time = CMTimeMakeWithSeconds(position, preferredTimescale: timescale!)
        if !self.isSeeking{
            self.isSeeking = true
            self.avPlayer.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { _ in
                self.isSeeking = false
            })
        }
    }
    
    // for video trim
    func trimVideo(sourceURL: URL, destinationURL: URL, trimPoint: (CMTime, CMTime), completion: ((Error?) -> Void)?) {
        let asset = AVAsset(url: sourceURL)
        let maxSize = CGSize(width: 1920, height: 1080)
        let videoSize = sourceURL.resolutionForLocalVideo()
        var preferredPreset = AVAssetExportPresetHighestQuality
        
        guard let size = videoSize else {
            return
        }
        
        if size.width > maxSize.width && size.height > maxSize.height {
            preferredPreset = AVAssetExportPresetMediumQuality
        }
        
        let timeRange = CMTimeRange(start: trimPoint.0, end: trimPoint.1)

        exportSession = AVAssetExportSession(asset: asset, presetName: preferredPreset)
        exportSession.outputURL = destinationURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.timeRange = timeRange
        
        removeFileAtURLIfExists(url: destinationURL)
        
        exportSession.exportAsynchronously {
            if let completion = completion {
                completion(self.exportSession.error)
            }
        }
    }

    func cutSelect(){
        rangeSlider.startIndicator.isHidden = false
        rangeSlider.progressIndicator.isHidden = false
        rangeSlider.endIndicator.isHidden = false
        rangeSlider.topLine.isHidden = false
        rangeSlider.bottomLine.isHidden = false
        slider_view.isHidden = false
        btnPlay.isHidden = false
        rangeSlider.progressIndicator.isUserInteractionEnabled = true
        
        rangeSlider.startModelView.isHidden = false
        rangeSlider.endModelView.isHidden = false
        
        //커버부분 가리기
        videoTime_label.text = Int(self.endTime - self.startTime).toColonTime
        thumbnail_view.isHidden = true
        thumbnail_modal_view.isHidden = true
        
        rangeSlider.duration = CMTimeGetSeconds((self.avPlayer.currentItem?.duration)!)
        rangeSlider.updateThumbnails(duration: CMTimeGetSeconds((self.avPlayer.currentItem?.duration)!), startTime: Float(0))
    }
    
    
    func coverSelect(){
        rangeSlider.progressIndicator.isHidden = true
        rangeSlider.startIndicator.isHidden = true
        rangeSlider.endIndicator.isHidden = true
        rangeSlider.topLine.isHidden = true
        rangeSlider.bottomLine.isHidden = true
        slider_view.isHidden = true
        btnPlay.isHidden = true
        videoTime_label.text = "커버사진 선택"
        rangeSlider.progressIndicator.isUserInteractionEnabled = false
        
        
        thumbnail_modal_view.isUserInteractionEnabled = true
        thumbnail_modal_view.isHidden = false
        
        thumbnail_view.isHidden = false
        
        rangeSlider.startModelView.isHidden = true
        rangeSlider.endModelView.isHidden = true
        
        
        avPlayer.pause()
        
        
        rangeSlider.duration = Float64(self.endTime - self.startTime)
        cutTime = Float64(self.endTime - self.startTime)
        
        rangeSlider.updateThumbnails(duration: cutTime, startTime: Float(startTime))
    }
    
    @objc func coverDragged(_ sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: thumbnail_view)
        var time = 0

        if sender.state == .began {
            thumbnail_view.frame.origin = CGPoint(x: sender.location(in: rangeSlider).x, y: thumbnail_view.frame.origin.y)
        }
        
        
        thumbnail_view.isHidden = false

        if thumbnail_view.frame.origin.x < rangeSlider.frame.origin.x {
            thumbnail_view.frame.origin = CGPoint(x: rangeSlider.frame.origin.x, y: thumbnail_view.frame.origin.y)
            time = -40
        }
        else if thumbnail_view.frame.origin.x + thumbnail_view.frame.width > rangeSlider.frame.origin.x + rangeSlider.frame.width {
            thumbnail_view.frame.origin = CGPoint(x: rangeSlider.frame.origin.x + rangeSlider.frame.width - thumbnail_view.frame.width, y: thumbnail_view.frame.origin.y)
            time = 40
        }
        else {
            thumbnail_view.center = CGPoint(x: thumbnail_view.center.x + translation.x, y: thumbnail_view.center.y)
            sender.setTranslation(CGPoint.zero, in: self.view)
            
            if thumbnail_view.center.x > view.frame.width/2 {
                time = 40
            }
            else{
                time = -40
            }
        }
        
        percentage = ((thumbnail_view.frame.origin.x + CGFloat(time)) * CGFloat(cutTime)) / (rangeSlider.frame.width)
        initializeProgressBar(position: Float64(percentage) + startTime)      //cutTime 자르기 했으면 자른 시간 만큼 더해준다
    }
}
