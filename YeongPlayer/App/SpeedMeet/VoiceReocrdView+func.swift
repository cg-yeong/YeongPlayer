//
//  VoiceReocrdView+func.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/23.
//

import Foundation
import AVFoundation
import Lottie
import Photos

extension VoiceRecordView {
    
    
    
    func pumpLottieAni(_ on: Bool) {
        guard on else {
            pumpLottie.stop()
            return
        }
        let animation = Animation.named("recording_pump", subdirectory: "LottieImage")
        DispatchQueue.main.async {
            self.pumpLottie.animation = animation
            self.pumpLottie.frame = self.pumpLottieView.bounds
            self.pumpLottie.contentMode = .scaleAspectFit
            self.pumpLottieView.addSubview(self.pumpLottie)
            self.pumpLottie.play(fromProgress: 0, toProgress: 1, loopMode: .loop) { _ in
                
            }
        }
    }
    
    func setRecordView(_ mode: recordState) {
        switch mode {
        case .ready:
            recordSendBtn.isHidden = true
            reRecordBtn.isHidden = true
            recordingBtn.setImage(UIImage(systemName: "mic", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
            noticeLabel.text = "\(recordModel.minSec.toTime)이상 \(recordModel.maxSec.toTime)까지 녹음 가능" // 1초 이상 10분까지
            progressView.progress.stopAnimation()
        case .recordStart:
            // lottie
            pumpLottieAni(true)
            recordingBtn.setImage(UIImage(systemName: "stop.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
            recordSendBtn.isHidden = true
            reRecordBtn.isHidden = true
            noticeLabel.text = "00:00"
            progressView.setProgress(TimeInterval(recordModel.maxSec)!)
        case .playStart:
            pumpLottieAni(true)
            recordingBtn.setImage(UIImage(systemName: "stop.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
            reRecordBtn.isHidden = true
            recordSendBtn.isHidden = true
            progressView.setProgress(self.audioPlayer!.duration)
            noticeLabel.text = "녹음이 완료되었습니다!\n멋진 목소리를 등록하시겠습니까?"
        case .recordStop, .playStop:
            pumpLottieAni(false)
            recordingBtn.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
            reRecordBtn.isHidden = false
            recordSendBtn.isHidden = false
            progressView.progress.stopAnimation()
            noticeLabel.text = "녹음이 완료되었습니다!\n멋진 목소리를 등록하시겠습니까?"
        }
    }
    
    func motionRecord() {
        switch nowRecordState {
        case .ready:
            viewModel.recordStart(self.audioRecorder) { recorder, result in
                if result {
                    self.audioRecorder = recorder
                    DispatchQueue.main.async {
                        self.repeatUpdateRecordTimer()
                        self.nowRecordState = .recordStart
                        self.setRecordView(self.nowRecordState)
                        self.audioRecorder?.delegate = self
                    }
                }
            }
        case .recordStart:
//            self.audioRecorder?.stop()
            if let recorder = self.audioRecorder {
                viewModel.recordStop(recorder) {
                    self.resultTime = Int(recorder.currentTime)
                }
            }
        case .playStart:
            if let player = self.audioPlayer {
                viewModel.playStop(player) {
                    self.audioPlayerDidFinishPlaying(player, successfully: true)
                }
            }
        case .recordStop, .playStop:
            if let player = self.audioPlayer {
                player.delegate = self
                viewModel.playStart(player) { result in
                    if result == true {
                        self.nowRecordState = .playStart
                        self.setRecordView(self.nowRecordState)
                    }
                }
            } else {
                log.s("Could not make player")
            }
        case .none:
            break
        }
    }
    func repeatUpdateRecordTimer() {
        self.recordTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(recordControlProgress), userInfo: nil, repeats: true)
    }
    
    @objc func recordControlProgress() {
        if nowRecordState == .recordStart {
            self.audioRecorder?.updateMeters()
            noticeLabel.text = viewModel.printProgressTime((audioRecorder?.currentTime) ?? 0, false)
        } else if nowRecordState == .playStart {
            if audioPlayer != nil {
                noticeLabel.text = viewModel.printProgressTime((audioPlayer?.currentTime) ?? 0, false)
            }
        } else if nowRecordState == .recordStop || nowRecordState == .playStop {
            if audioPlayer != nil {
                noticeLabel.text = viewModel.printProgressTime(audioPlayer!.duration + 0.1, false)
            }
        }
    }
    
    // 전화나 알림이 올때 백그라운드 작업하기
    @objc func handleInterruption(_ noti: Notification) {
        guard let info = noti.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              // enum InterruptionType: UInt 오디오 중단 유형을 설명하는 상수
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        if type == .began { // 인터럽트가 시작
            log.d("스톱")
            self.audioPlayer?.stop()
            
            
            
        } else if type == .ended { // 인터럽트가 끝났을 때
            guard let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt else {
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                log.d("정지")
            }
        }
    }
    
    func stopAudio() {
        self.audioRecorder = nil
        self.audioPlayer = nil
        self.nowRecordState = .ready
        self.setRecordView(self.nowRecordState)
    }
    
    func sendFile() {
        self.audioConverter()
    }
    
    func audioConverter() {
        // indicator on, startAnimation()
        DispatchQueue.global().async {
            if self.audioPlayer == nil { return }
            
            let recordingFilePath_mp3 = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("\(String(Int(Date().timeIntervalSince1970))).mp3")
            
            // convert m4a -> mp3
            let converter = ExtAudioConverter()
            converter.inputFile = self.audioPlayer?.url?.path
            converter.outputFile = recordingFilePath_mp3.absoluteString.replacingOccurrences(of: "file://", with: "")
            converter.outputSampleRate = 44100
            converter.outputNumberChannels = 2
            converter.outputFormatID = kAudioFormatMPEGLayer3
            converter.outputFileType = kAudioFormatMPEGLayer3
            converter.convert()
            
            if let audioData = try? Data(contentsOf: recordingFilePath_mp3, options: .mappedRead) {
                Utility.delayExecute(0) {
                    Toast.showOnXib("보내는 거 아직 구현 안했음")
                }
            } else {
                DispatchQueue.main.async {
                    Toast.showOnXib("녹음한 파일이 존재 안함 \n다시 녹음해줘", duration: 2.0)
                }
                
                self.close()
            }
            
        }
    }
    
    func close() {
        recordTimer?.invalidate()
        if recordTimer != nil {
            recordTimer = nil
        }
        audioRecorder?.stop()
        audioRecorder = nil
        audioPlayer?.stop()
        audioPlayer = nil
        
//        removeFromSuperview()
//        UIApplication.shared.isIdleTimerDisabled = false
//        NotificationCenter.default.removeObserver(self)
    }
    
    func sendMessage() {
        let trimmedMsg = txtInput.text?.trimmingCharacters(in: .whitespaces)
        if trimmedMsg?.isEmpty == false {
            chatData.append(MsgModel(status: ChatCell, record: nil, chat: trimmedMsg))
        }
        
        txtInput.text = ""
        chatCollectionView.reloadData()
    }
    
    
    func setFetchPhoto() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.fetchResults = PHAsset.fetchAssets(with: fetchOptions)
        self.photoCollectionView.reloadData()
    }
    
}
