//
//  LocalImageManager.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/20.
//

import Foundation
import Photos
import UIKit

final class LocalImageManager {
    
    static let shared = LocalImageManager()
    
    fileprivate let imageManager = PHCachingImageManager()
    
    var representedAssetIdentifier: String?
    
    func requestImage(with asset: PHAsset?, thumbnailSize targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        guard let asset = asset else {
            completion(nil)
            return
        }
        
        self.representedAssetIdentifier = asset.localIdentifier
        
        let imageOptions = PHImageRequestOptions()
        imageOptions.isSynchronous = true
        imageOptions.resizeMode = .fast
        imageOptions.isNetworkAccessAllowed = true
        imageOptions.deliveryMode = .highQualityFormat
        
        self.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: imageOptions, resultHandler: { (image, info) in
            
            completion(image)
            
        })
    }
}
