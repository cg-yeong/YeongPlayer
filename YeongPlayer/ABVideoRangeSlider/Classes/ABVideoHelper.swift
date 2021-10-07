//
//  ABVideoHelper.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/15.
//

import UIKit
import AVFoundation

class ABVideoHelper: NSObject {
    
    static func thumbnailFromVideo(videoURL: URL, time: CMTime) -> UIImage {
        let asset: AVAsset = AVAsset(url: videoURL)
        let imgGenerator = AVAssetImageGenerator(asset: asset)

        imgGenerator.appliesPreferredTrackTransform = true // default: false, 90, 180, 270 회전 지원
        imgGenerator.maximumSize = CGSize(width: 100, height: 100)

        do {
            
            let cgImage = try imgGenerator.copyCGImage(at: time, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
        
        } catch {
            
        }
        return UIImage()
        
    }
    
    static func videoDuration(videoURL: URL) -> Float64 {
        let source = AVURLAsset(url: videoURL)
        return CMTimeGetSeconds(source.duration)
    }
    
}
