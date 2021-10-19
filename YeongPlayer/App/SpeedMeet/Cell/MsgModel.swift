//
//  MsgModel.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/28.
//

import Foundation

struct MsgModel {
    
    var status: String?
    var record: RecordingMsg?
    var chat: String?
    
}

//---------=---------

struct RecordingMsg {
    var filePath: URL // recordingFilePath_mp3
    
    init(filePath: URL) {
        self.filePath = filePath
    }
}
