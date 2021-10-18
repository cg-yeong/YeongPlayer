//
//  VideoRecordVC.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/10.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import Photos

final class VideoRecordVC: UIViewController {
    
    
    //@IBOutlet weak var cameraPreview: preview!
    @IBOutlet weak var cameraPreview: PreviewView!
    @IBOutlet weak var controllerView: UIView!
    @IBOutlet weak var subControllerView: UIView!
    
    @IBOutlet weak var closeRecord: UIButton!
    @IBOutlet weak var torchBtn: UIButton!
    @IBOutlet weak var openGalleryBtn: UIButton!
    @IBOutlet weak var flipCamera: UIButton!
    
    @IBOutlet weak var recording: UIButton!
    
    @IBOutlet weak var circleImage: UIImageView!
    @IBOutlet weak var flipImage: UIImageView!
    
    @IBOutlet weak var isVideoSwitch: UISwitch! // on : video , off: photo, if isOn {}
    
    let circleStartImage = UIImage(named: "vi2_club_msg_df")
    let circleStopImage = UIImage(named: "vi2_club_msg_shooting")
    
    let bag = DisposeBag()
    let session = AVCaptureSession()
    
    
    // ---------------------------------s
    // MARK: Session Management
    private enum SessionSetUpResult {
        case success
        case notAuthorized
        case configureationFailed
    }
    let sessionQueue = DispatchQueue(label: "session queue")
    var isSessionRunning = false
    
    private var setupResult: SessionSetUpResult = .success // 세션 구성 확인 플래그
    
    var videoDeviceInput: AVCaptureDeviceInput! // @objc dynamic var
    // -----------------------------------
    // MARK: device configuration
    let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera, .builtInDualWideCamera], mediaType: .video, position: .unspecified)
    
    // MARK: Capturing Photos
    let photoOutput = AVCapturePhotoOutput()
    // MARK: Recording Movies
    var movieFileOutput: AVCaptureMovieFileOutput?
    var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    enum captureMode: Int {
        case photo = 0
        case movie = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recording.layer.cornerRadius = recording.bounds.size.width / 2
        recording.clipsToBounds = true
        recording.layer.borderWidth = 2
        recording.layer.borderColor = UIColor.white.cgColor
        
        cameraPreview.session = session
        
        
        bind()
        checkPermission()
        setupSession()
    }
    func bind() {
        
        closeRecord.rx.tap
            .bind { _ in
                self.dismiss(animated: true, completion: nil)
            }.disposed(by: bag)
        
        flipCamera.rx.tap
            .bind { _ in
                // 세션 중지 -> 세션 디바이스 다시 설정 -> 세션 시작
//                self.changeCamera()
                self.changeCam()
            }.disposed(by: bag)
        
        recording.rx.tap
            .bind { _ in
                print("녹화 버튼 눌러")
                if self.isVideoSwitch.isOn {
                    self.movieRecord()
                } else {
                    self.capturePhoto()
                }
                
            }.disposed(by: bag)
        
        isVideoSwitch.rx.controlEvent(.valueChanged)
            .withLatestFrom(isVideoSwitch.rx.value)
            .subscribe(onNext: { isvideo in
                print(isvideo) // true or false: Bool
                self.toggleCaptureMode(isvideo)
                
            }).disposed(by: bag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }



    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted { self.setupResult = .notAuthorized }
                self.sessionQueue.resume()
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            // 전에 미리 권한 받아놓은 상태라 break 가능
            break
        @unknown default:
            setupResult = .notAuthorized
        }
        
        sessionQueue.async {
            self.setupSession()
        }
    }
    func setupSession() {
        /**
         프리셋 설정, 설정 시작,
         인풋 추가 아웃풋 추가
         설정 커밋
         */
        print(setupResult)
        if setupResult != .success {
            return
        } // 중복 세션 구성 방지 플래그
        
        
//        session.sessionPreset = .high
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        // add video input
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            if let dualCam = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCam
            } else if let dualwideCam = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
                defaultVideoDevice = dualwideCam
            } else if let backCam = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                defaultVideoDevice = backCam
            } else if let frontCam = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                defaultVideoDevice = frontCam
            }
            guard let videoDevice = defaultVideoDevice else {
                
                print("기본 비디오 사용불가능")
                setupResult = .configureationFailed
                session.commitConfiguration()
                return
            }
            
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                self.videoDeviceInput = videoInput
                
                // Previewlayer - cameraPreview 는 UI관련 작업이라 Main 스레드에서만 가능
                DispatchQueue.main.async {
                    self.cameraPreview.videoPreviewLayer.connection?.videoOrientation = .portrait
                }
            } else {
                print("비디오 인풋 세션에 추가 못함")
                setupResult = .configureationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("비디오 인풋 만들기 실패\(error)")
            setupResult = .configureationFailed
            session.commitConfiguration()
            return
        }
        
        // 오디오 인풋 추가
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)!
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            
            if session.canAddInput(audioInput) {
                session.addInput(audioInput)
            } else {
                print("세션에 오디오 장치 추가 못함")
            }
        } catch {
            print("오디오 장치 못만듬\(error)")
        }
        
        // 사진 아웃풋 추가
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
        } else {
            print("사진 아웃풋 세션에 추가 못함")
            setupResult = .configureationFailed
            session.commitConfiguration()
            return
        }
        session.commitConfiguration()
        session.startRunning()
    }
    
    func toggleCaptureMode(_ captureModeSwitch: Bool) {
        isVideoSwitch.isEnabled = false
        
        if captureModeSwitch {
            // true video
//            isVideoSwitch.isOn
            sessionQueue.async {
                let movieFileOutput = AVCaptureMovieFileOutput()
                
                if self.session.canAddOutput(movieFileOutput) {
                    self.session.beginConfiguration()
                    self.session.addOutput(movieFileOutput)
                    self.session.sessionPreset = .high
                    
                    if let connection = movieFileOutput.connection(with: .video) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    self.session.commitConfiguration()
                    DispatchQueue.main.async {
                        self.isVideoSwitch.isEnabled = true
                    }
                    self.movieFileOutput = movieFileOutput
                }
            }
            
        } else {
            // false photo
            sessionQueue.async {
                self.session.beginConfiguration()
                self.session.removeOutput(self.movieFileOutput!)
                self.session.sessionPreset = .photo
                
                DispatchQueue.main.async {
                    self.isVideoSwitch.isEnabled = true
                }
                
                self.movieFileOutput = nil
                
                self.session.commitConfiguration()
            }
        }
        
    }
    func changeCam() {
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            let backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
            let frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera], mediaType: .video, position: .front)
            var newVideoDevice: AVCaptureDevice? = nil
            
            switch currentPosition {
            case .unspecified, .front:
                newVideoDevice = backVideoDeviceDiscoverySession.devices.first
            case .back:
                newVideoDevice = frontVideoDeviceDiscoverySession.devices.first
            @unknown default:
                print("앞뒤 안정해져서 기본값인 뒤하고 듀얼카메라로 설정")
                newVideoDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
            }
            
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    self.session.beginConfiguration()
                    
                    // AVCaptureSession이 앞뒤 카메라 동시 입력이 지원 하지 않아서
                    // 세션에 전에 존재하던 입력장치(전 카메라)를 지워주기
                    self.session.removeInput(self.videoDeviceInput)
                    // 새 입력장치(카메라) 들어갈 수 있나 ?
                    if self.session.canAddInput(videoDeviceInput) {
                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        // 장치 추가 못하면 전에 있던 장치 가져와서 넣어주기
                        self.session.addInput(self.videoDeviceInput)
                    }
                    // 추가하고 연결 점검?
                    if let connection = self.movieFileOutput?.connection(with: .video) {
                        self.session.sessionPreset = .high
                        
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    
                    self.session.commitConfiguration()
                } catch {
                    print("비디오 장치 만드는중 에러 \(error)")
                }
            }
            // DispatchQueue UI - main 작업
        }
    }
    
    @objc func changeCamera() {
        guard let currentInput = session.inputs.first(where: { input in
            guard let input = input as? AVCaptureDeviceInput else { return false }
            return input.device.hasMediaType(.video)
        }) as? AVCaptureDeviceInput else { return }
        
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        var newDevice: AVCaptureDevice?
        if currentInput.device.position == .back {
            newDevice = camPosition(in: .front)
        } else {
            newDevice = camPosition(in: .back)
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: newDevice!)
            session.removeInput(currentInput)
            session.addInput(videoInput)
        } catch {
            print(error.localizedDescription)
        }
        
    }

    func camPosition(in position: AVCaptureDevice.Position) -> AVCaptureDevice? {

        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    func capturePhoto() {
        let videoPreviewLayerOrientation = cameraPreview.videoPreviewLayer.connection?.videoOrientation
        
        sessionQueue.async {
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation ?? .portrait
            }
            var photoSettings = AVCapturePhotoSettings()
            
            // HEIF 사진 (지원되면)
            if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.hevc])
            }
            
            if self.videoDeviceInput.device.isFlashAvailable {
                photoSettings.flashMode = .auto
            }
            
            photoSettings.isHighResolutionPhotoEnabled = true
            // previewPhotoPixelFormatTypes
            // livephoto
            // detpdatadelivery
            // isportraiteffectsmatteDelivery
            // isDepthDataDelibery
            
            
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
        DispatchQueue.main.async {
            self.recording.alpha = 0
            self.circleImage.alpha = 0
            UIView.animate(withDuration: 0.25) {
                self.recording.alpha = 1
                self.circleImage.alpha = 1
            }
        }
    }
    
    func movieRecord() {
        guard let movieFileOutput = self.movieFileOutput else { return }
        // 녹화 완료까지 카메라 관련 작동 안하게 설정해야 함
        // 타이머 설정으로 321 할건지
        
        isVideoSwitch.isEnabled = false
        circleImage.image = circleStopImage
        
        let videoPreviewLayerOrientation = cameraPreview.videoPreviewLayer.connection?.videoOrientation
        
        sessionQueue.async {
            if !movieFileOutput.isRecording {
                // 녹화중이 아니라면
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                // 녹화전에 동영상 파일 출력 비디오 연결의 방향을 업데이트
                let movieFileOutputConnection = movieFileOutput.connection(with: .video)
                movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation ?? .portrait
                
                let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
                if availableVideoCodecTypes.contains(.hevc) {
                    movieFileOutput.setOutputSettings([AVVideoCodecKey : AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                }
                
                // 비디오 녹화 임시파일
                let outputFileName = NSUUID().uuidString
//                UUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mp4")!)
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            } else {
                movieFileOutput.stopRecording()
                DispatchQueue.main.async {
                    self.circleImage.image = self.circleStartImage
                    self.isVideoSwitch.isEnabled = true
                }
            }
        }
        
    }
    
    
}

extension VideoRecordVC: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        func cleanup() {
            let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("파일을 지울수 없어 \(outputFileURL)")
                }
            }
            if let currentBackgroundRecordingID = backgroundRecordingID {
                backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
                
                if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                    UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                }
            }
        }
        
        var success = true
        
        if error != nil {
            print("error recording movie: \(error!.localizedDescription)")
            print("Movie file finishing error: \(String(describing: error))")
            success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
        }
        
        if success {
            
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges {
                        let options = PHAssetResourceCreationOptions()
                        options.shouldMoveFile = true
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                        
                    } completionHandler: { success, error in
                        if !success {
                            print("카메라에서 앨범으로 동영상 저장 못햇어 : \(String(describing: error))")
                        }
                        cleanup()
                    }
                    
                } else {
                    cleanup()
                }
            }
            
            let videoRecorded = outputFileURL
            UISaveVideoAtPathToSavedPhotosAlbum(videoRecorded.path, nil, nil, nil)
            
            DispatchQueue.main.async {
                guard let editVC = self.storyboard?.instantiateViewController(identifier: "videoEditor") as? VideoEditorVC else { return }
                editVC.modalPresentationStyle = .fullScreen
                editVC.videoPath = outputFileURL.absoluteString
                editVC.from = "camera"
                self.present(editVC, animated: true, completion: nil)
            }
            
        } else {
            cleanup()
        }
        
    }
}

extension VideoRecordVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
  
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
    }
}
