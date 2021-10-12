//
//  AttachmentInputPhoto.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/12.
//

import UIKit
import Photos
import RxSwift

class AttachmentInputPhoto {
    
    struct PhotoProperties {
        var filename: String
        var fileSize: Int64
        var exceededSizeLimit: Bool
    }
    
    private let bag = DisposeBag()
    private var initialized: Bool = false
    // AsyncSubject: 구독 이후 이벤트만 받음
    private let thumbnailSubject = AsyncSubject<UIImage?>()
    private let propertiesSubject = AsyncSubject<PhotoProperties?>()
    private let videoTimeSubjcet = AsyncSubject<String?>()
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
    
    /// @param: asset: PHAsset
    /// @param: uploadSizeLimit
    /// @param: imageManager
    /// @return self of nil: 사진과 비디오가 아닐때 nil을 리턴
    init?(asset: PHAsset, uploadSizeLimit: Int64, imageManager: PHImageManager) {
        if (asset.mediaType != .video && asset.mediaType != .image) {
            return nil
        }
        
        self.asset = asset
        self.thumbnail = self.thumbnailSubject
            .filter { $0.map { $0 } != nil }    // filter { Type? != nil }
            .map { ($0.map { $0 })! }           // map { (Type?)! }
            .asObservable()
        self.properties = self.propertiesSubject.unwrap().asObservable()
        self.isVideo = (asset.mediaType == .video)
        self.videoTime = self.videoTimeSubjcet.unwrap().asObservable()
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
            
        }
    }
    
    func loadThumbnail(photoSize: CGSize, resizeMode: PHImageRequestOptionsResizeMode) -> Observable<UIImage?> {
        
        let dataSubject = AsyncSubject<UIImage?>()
        let option = PHImageRequestOptions()
        option.deliveryMode = .highQualityFormat
        option.resizeMode = resizeMode
        option.isSynchronous = true
        option.isNetworkAccessAllowed = true
        
        let cachingManager = PHCachingImageManager()
        cachingManager.requestImage(for: asset, targetSize: photoSize, contentMode: .aspectFill, options: option, resultHandler: { image, info in
            if let image = image {
                dataSubject.onNext(image)
                dataSubject.onCompleted()
            } else {
                dataSubject.onError(AttachmentInputError.thumbnailLoadFailed)
            }
        })
        return dataSubject.asObservable()
    }
    
    
    func loadProperties(phAsset: PHAsset) {
        self.propertiesSubject.onNext(PhotoProperties(filename: "",
                                                      fileSize: 0,
                                                      exceededSizeLimit: false))
        self.videoTimeSubjcet.onNext(phAsset.duration.minuteSecond)
        self.videoTimeSubjcet.onCompleted()
        self.propertiesSubject.onCompleted()
    }
    
}
