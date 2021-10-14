//
//  AttachmentInputUtil.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/08.
//

import Foundation
import UIKit
import Photos
import RxSwift

class AttachmentInputUtil {
    
    
    
    /// 파일 URL에서 파일 사이즈 구하기
    static func getSizeFromFileUrl(fileUrl: URL) -> Int64? {
        var resultSize: Int64?
        /// 파일 속성 - 파일매니저에서 파일 경로 가져오기
        /// attributesOfItem(atPath: string) ->? [FileAttributeKey : Any]
        if let fileAttribute = try? FileManager.default.attributesOfItem(atPath: fileUrl.path) {
            // 값 : Any as? Int64
            if let fileSize = fileAttribute[FileAttributeKey.size] as? Int64 {
                resultSize = fileSize
            }
        }
        return resultSize
    }
    
    /**
     파일 압축
     ******************************************************
     */
    
    static func compressImage(image: UIImage, photoQuality: Float) -> Data? {
        let quality = CGFloat(photoQuality)
        return image.jpegData(compressionQuality: quality)
    }
    
    static func compressVideo(avAsset: AVAsset, outputUrl: URL?, videoQuality: UIImagePickerController.QualityType) -> (result: Observable<Void>, onCancel: AnyObserver<Void>) {
        let compressSubject = AsyncSubject<Void>()
        let cancelSubject = PublishSubject<Void>()
        
        let videoQuality = videoQuality
        let qualityPresetName = AttachmentInputUtil.getAVAssetExportPresetQuality(from: videoQuality)
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: qualityPresetName)
        
        if let exportSession = exportSession, let ouputUrl = outputUrl {
            // 이미 같은 파일이 있다면 삭제
            try? FileManager.default.removeItem(at: ouputUrl)
            
            // 영상 압축!
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
                // 종료되면 취소는 더이상 필요하지 않음
                cancelSubject.dispose()
            }
        } else {
            compressSubject.onError(AttachmentInputError.compressVideoFailed)
            cancelSubject.dispose()
        }
        
        // it do not use return value to "dispose" by ourselves
        _ = cancelSubject.subscribe(onNext: { _ in
            exportSession?.cancelExport()
        })
        
        return (compressSubject, cancelSubject.asObserver())
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
    
    /// UIImagePickerController 퀄리티에 해당하는 AVAsset 추출 프리셋 x 퀄리티 가져오기
    static private func getAVAssetExportPresetQuality(from qualityType: UIImagePickerController.QualityType) -> String {
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
    
    /**
     파일 추가
     ******************************************************
     */
    
    /// Change or add extensions
    /// 확장자 변경 혹은 추가
    static func addFilenameExtension(fileName: String, extensionString: String) -> String {
        // ~/ABCDE.mp4 -> ~/ -> ~/ABCDE.MOV
        /// 경로 "/ " 개수 세기
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
    
    /// 표시위한 현재시간을 문자열로
    /// 현재 촬영한 시각을 활용한 이름으로 활용
    static func datetimeForDisplay(from: Date) -> String {
        let format = DateFormatter()
        format.locale = Locale.current
        format.timeZone = TimeZone.current
        format.dateStyle = .medium // “Nov 23, 1937” or “3:30:32 PM”
        format.timeStyle = .short // “11/23/37” or “3:30 PM”.
        return format.string(from: from)
    }
    
}
