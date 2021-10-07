//
//  RecordViewModel+AudioControl.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/28.
//

import UIKit
import AVFoundation

extension RecordViewModel {
    
    func recordStart(_ audioRecorder: AVAudioRecorder?, _ completion: ((AVAudioRecorder, Bool) -> Void)!) {
        var audioRecorder = audioRecorder
        let soundM4AFileURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("recording\(NSUUID().uuidString).m4a")
        log.d(soundM4AFileURL)
        let recordSettings = [
            AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
            AVNumberOfChannelsKey : NSNumber(value: 2),
            AVSampleRateKey : NSNumber(value: Int32(44100)),
            AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.max.rawValue))
        ]
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { allowed in
            if allowed {
                do {
                    try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                    try audioRecorder = AVAudioRecorder(url: soundM4AFileURL, settings: recordSettings)
                    audioRecorder?.prepareToRecord()
                    audioRecorder?.isMeteringEnabled = true
                    if audioRecorder?.record(forDuration: Double(self.recordModel.value.maxSec)!) != nil {
                        completion(audioRecorder!, true)
                    } else {
                        completion(AVAudioRecorder(), false)
                        print(" 녹음 실패 ㅠㅠ ")
                    }
                } catch {
                    completion(AVAudioRecorder(), false)
                    print("오디오 세션 오류 ")
                }
            } else {
                completion(AVAudioRecorder(), false)
                print(" ㅋㅋ 녹음 권한 없대")
                let alert = UIAlertController.init(title: "마이크 내놔", message: "설정할거야?", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                })
                let cancel = UIAlertAction(title: "ㄴㄴ", style: .cancel, handler: nil)
                alert.addAction(ok)
                alert.addAction(cancel)
                (App.module.presenter.visibleViewController as? ViewController)?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func recordStop(_ audioRecorder: AVAudioRecorder, _ completion: (() -> Void)!) {
        if Int(audioRecorder.currentTime) < Int(self.recordModel.value.minSec)! {
//            Toast.show("최소 \(self.recordModel.value.minSec)초 이상 녹음해주세요!", duration: 2.0)
            Toast.showOnXib("최소 \(self.recordModel.value.minSec)초 이상 녹음해주세요!", duration: 2.0)
        } else {
            audioRecorder.stop()
        }
        completion()
    }
    
    func playStart(_ audioPlayer: AVAudioPlayer, _ completion: ((Bool) -> Void)!) {
        if audioPlayer.prepareToPlay() && audioPlayer.play() {
            completion(true)
        } else {
            completion(false)
            log.s("Could not start Player...")
        }
    }
    
    func playStop(_ audioPlayer: AVAudioPlayer, _ completion: (() -> Void)!) {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        completion()
    }
    
}
