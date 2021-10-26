//
//  AttachmentInputPhoto.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/25.
//

import UIKit
import RxSwift
import Photos

class AttachmentInputPhoto {
    
    struct PhotoProperties {
        var fileName: String
        var fileSize: Int64
        var exceededSizeLimit: Bool
    }
    
    private let disposeBag = DisposeBag()
    private var initialized: Bool = false
    private let thumbnailSubject = AsyncSubject<UIImage?>()
    private let propertiesSubject = AsyncSubject<PhotoProperties?>()
    private let videoTimeSubject = AsyncSubject<String?>()
    private let uploadSizeLimit: Int64
    private let imageManager: PHImageManager
    
    // output
    let asset: PHAsset
    let thumbnail: Observable<UIImage>
    let isVideo: Bool
    let identifier: String
    var videoTime: Observable<String>
    var selectIndex: Int = 0
    let properties: Observable<PhotoProperties>
    
    init?(asset: PHAsset, uploadSizeLimit: Int64, imageManager: PHImageManager) {
        if (asset.mediaType != .video && asset.mediaType != .image) {
            return nil
        }
        
        self.asset = asset
        self.thumbnail = self.thumbnailSubject.unwrap().asObservable()
        self.properties = self.propertiesSubject.unwrap().asObservable()
        self.isVideo = (asset.mediaType == .video)
        self.videoTime = self.videoTimeSubject.unwrap().asObservable()
        self.identifier = asset.localIdentifier
        self.uploadSizeLimit = uploadSizeLimit
        self.imageManager = imageManager
    }
    
    func initializeIfNeed(loadThumbnail: Bool) {
        if self.initialized == true {
            return
        }
        self.initialized = true
        self.loadProperties(phAsset: asset)
        
        if loadThumbnail {
            let _ = self.loadThumbnail(photoSize: AttachmentInputViewLogic.PHOTO_TILE_THUMBNAIL_SIZE, resizeMode: .fast)
                .take(1) // Observable<UIImage?>.take(1)
                .bind(to: self.thumbnailSubject)
        }
        
    }
    
    
    func loadThumbnail(photoSize: CGSize, resizeMode: PHImageRequestOptionsResizeMode) -> Observable<UIImage?> {
        // like thumbnailSubject: AsyncSubject
        let dataSubject = AsyncSubject<UIImage?>()
        let option = PHImageRequestOptions()
        option.deliveryMode = .highQualityFormat
        option.resizeMode = resizeMode
        option.isSynchronous = true
        option.isNetworkAccessAllowed = true
        
        let cachingManager = PHCachingImageManager()
        cachingManager.requestImage(for: asset, targetSize: photoSize, contentMode: .aspectFill, options: option, resultHandler: { image, info in
            if let image = image {
                dataSubject.onNext(image) // 전달해주고
                dataSubject.onCompleted() // 완료해야지 subject -> observable로 전달됨
            } else {
                dataSubject.onError(AttachmentInputError.thumbnailLoadFailed)
            }
        })
        return dataSubject.asObservable()
    }
    
    private static let serialDispatchQueue = DispatchQueue(label: "attachmentInputPhoto.dispatchqueue.serial")
    private func loadProperties(phAsset: PHAsset) {
        // get meta data
        
        self.propertiesSubject.onNext(
            PhotoProperties(fileName: "",
                            fileSize: 0,
                            exceededSizeLimit: (0 != 0))
        )
        self.videoTimeSubject.onNext(phAsset.duration.minuteSecond)
        self.videoTimeSubject.onCompleted() // asyncSubject onNext 이후 onCompleted
        self.propertiesSubject.onCompleted()
    }
}
