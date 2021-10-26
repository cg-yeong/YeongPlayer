//
//  AttachmentInputUtil.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/25.
//

import Foundation
import UIKit
import AVFoundation
import RxSwift

class AttachmentInputUtil {
    static func getSizeFromFileUrl(fileUrl: URL) -> Int64? {
        var resultSize: Int64?
        if let fileAttribute = try? FileManager.default.attributesOfItem(atPath: fileUrl.path) {
            if let fileSize = fileAttribute[.size] as? Int64 {
                resultSize = fileSize
            }
        }
        return resultSize
    }
    
    static func compressImage(image: UIImage, photoQuality: Float) -> Data? {
        let quality = CGFloat(photoQuality)
        return image.jpegData(compressionQuality: quality)
    }
    
    static func compressVideo(avAsset: AVAsset, outputUrl: URL?, videoQuality: UIImagePickerController.QualityType) -> (result: Observable<Void>, onCancel: AnyObserver<Void>) {
        let compressSubject = AsyncSubject<Void>()
        let cancelSubject = PublishSubject<Void>() // 기본값 없음
        
        let videoQuality = videoQuality
        let qualityPresetName = AttachmentInputUtil.getAVAssetExportPresetQaulity(from: videoQuality)
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: qualityPresetName)
        
        if let exportSession = exportSession, let outputUrl = outputUrl {
            // 이미 outputURL에 있는 파일 제거
            try? FileManager.default.removeItem(at: outputUrl)
            
            // compress Video
            exportSession.outputURL = outputUrl
            exportSession.outputFileType = .mov
            exportSession.exportAsynchronously { () -> Void in
                if exportSession.status == .completed {
                    compressSubject.onNext(())
                    compressSubject.onCompleted()
                } else if exportSession.status == .cancelled {
                    compressSubject.onCompleted()
                } else {
                    compressSubject.onError(AttachmentInputError.compressVideoFailed)
                }
                cancelSubject.dispose()
            }
        } else {
            compressSubject.onError(AttachmentInputError.compressVideoFailed)
            cancelSubject.dispose()
        }
        
        _ = cancelSubject.subscribe(onNext: { _ in
            exportSession?.cancelExport()
        })
        
        return (compressSubject, cancelSubject.asObserver())
    }
    
    static private func getAVAssetExportPresetQaulity(from qualityType: UIImagePickerController.QualityType) -> String {
        switch (qualityType) {
        case .typeHigh:
            return AVAssetExportPresetHighestQuality
        case .typeMedium:
            return AVAssetExportPresetMediumQuality
        case .typeLow:
            return AVAssetExportPresetLowQuality
        case .type640x480:
            return AVAssetExportPreset640x480
        case .typeIFrame960x540:
            return AVAssetExportPreset960x540
        case .typeIFrame1280x720:
            return AVAssetExportPreset1280x720
        @unknown default:
            fatalError()
        }
    }
    
    static func resizeFill(image: UIImage, size newSize: CGSize) -> UIImage? {
        let widthRatio = newSize.width / image.size.width
        let heightRatio = newSize.height / image.size.height
        let ratio = max(widthRatio, heightRatio)
        
        let resizedSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        let newOrigin = CGPoint(x: (newSize.width - resizedSize.width) / 2, y: (newSize.height - resizedSize.height) / 2)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: newOrigin, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    static func addFilenameExtension(fileName: String, extensionString: String) -> String {
        let pathExtensionCount = (fileName as NSString).pathExtension.count
        var fileName = fileName
        if pathExtensionCount > 0 {
            fileName.removeLast(pathExtensionCount)
            fileName = fileName + extensionString
        } else {
            fileName = fileName + ".\(extensionString)"
        }
        
        return fileName
    }
    
    static func datetimeForDisplay(from: Date) -> String {
        let format = DateFormatter()
        format.locale = .current
        format.timeZone = .current
        format.dateStyle = .medium
        format.timeStyle = .short
        return format.string(from: from)
    }
}
