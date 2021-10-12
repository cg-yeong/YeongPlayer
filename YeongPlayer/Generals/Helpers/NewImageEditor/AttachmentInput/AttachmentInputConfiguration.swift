//
//  AttachmentInputConfiguration.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/12.
//

import Foundation
import SwiftyJSON
import UIKit

public class AttachmentInputConfiguration {
    
    public var photoQuality: Float = 0.8
    public var videoQuality: UIImagePickerController.QualityType = .type640x480
    public var videoOutputDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("clubVideo", isDirectory: true)
    public var fileSizeLimit: Int64 = 1024 * 1000 * 1000 // 1GB
    public var thumbnailSize = CGSize(width: 128 * UIScreen.main.scale, height: 128 * UIScreen.main.scale)
    public var photoCellCountLimit = 100000
    
    // 최대 선택 개수
    public var maxPhoto = 20
    public var maxVideo = 5
    public var maxSelect = 20
    public var maxFiles = 200 // 웹 업로드 최대 개수
    
    public var curPhoto = 0
    public var curVideo = 0
    
    public var currentVideoCount = 0
    
    public var maxVideoTime = 60.0
    public var minVideoTime = 10.0
    
    var jsonData = JSON()
    
    var galleryType: Gallerytype = .all
    
    public init() {  }
}
