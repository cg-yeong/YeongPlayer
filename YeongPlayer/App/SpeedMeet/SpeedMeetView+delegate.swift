//
//  VoiceRecordView+delegate.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/23.
//

import Foundation
import AVFoundation

extension SpeedMeetView: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    /* --- AVAudioRecorderDelegate --- */
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            nowRecordState = .recordStop
            setRecordView(nowRecordState)
            
            if audioRecorder != nil {
                self.audioPlayer = try? AVAudioPlayer(contentsOf: audioRecorder!.url)
                log.d(audioRecorder?.url)
                
            }
        } else {
            log.s("Stopping audio recording failed")
        }
    }
    
    
    /* --- AVAudioPlayerDelegate --- */
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            nowRecordState = .playStop
            setRecordView(nowRecordState)
            noticeLabel.text = viewModel.printProgressTime(player.duration, false)
        } else {
            log.s("Audio Player did not stop correctly")
        }
    }
}


