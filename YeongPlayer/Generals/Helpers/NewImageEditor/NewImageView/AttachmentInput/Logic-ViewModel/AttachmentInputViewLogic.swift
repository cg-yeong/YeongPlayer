//
//  AttachmentInputViewLogic.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/25.
//

import Foundation
import Photos
import RxSwift
import SwiftUI

class AttachmentInputViewLogic {
    private static let PHOTO_TILE_THUMBNAIL_LENGTH: CGFloat = 128.0
    static let PHOTO_TILE_THUMBNAIL_SIZE = CGSize(width: PHOTO_TILE_THUMBNAIL_LENGTH, height: PHOTO_TILE_THUMBNAIL_LENGTH)
    var isCamera = false
    
    private let disposeBag = DisposeBag()
    // imageManager는  첫사용시에 권한 물어야 하기에 lazy var
    lazy public var imageManager = PHImageManager()
    private let configuration: AttachmentInputConfiguration
    private let phFetchResultSubject = BehaviorSubject<PHFetchResult<PHAsset>?>(value: nil)
    private let photosWithStatusSubject = BehaviorSubject<[(photo: AttachmentInputPhoto,
                                                            status: AttachmentInputPhotoStatus,
                                                            selectIndex: AttachmentInputPhotoSelectIndex)]>(value: [])
    // (photo, status, selectIndex) tuple
    private let fileManager = FileManager.default
    
    // 상태와 사진은 구별하여 관리하기
    // 사진은 이미지 저장상태가 바뀔때마다 매번 바뀌지만
    // 상태는 앨범이 바뀔때 업데이트 되지 않아서
    public var statusDictionary: Dictionary<String, AttachmentInputPhotoStatus> = [:]
    public var selectIndex: Dictionary<String, AttachmentInputPhotoSelectIndex> = [:]
    
    weak var delegate: AttachmentInputDelegate?
    
    // input
    let pHFetchResultObserver: AnyObserver<PHFetchResult<PHAsset>?>
    
    // ouput
    var pHFetchResult: PHFetchResult<PHAsset>? {
        return self.phFetchResultSubject.value(nil)
    }
    var photosWithStatus: Observable<[(photo: AttachmentInputPhoto,
                                       status: AttachmentInputPhotoStatus,
                                       selectIndex: AttachmentInputPhotoSelectIndex)]>
    
    
    init(configuration: AttachmentInputConfiguration) {
        self.configuration = configuration
        self.pHFetchResultObserver = self.phFetchResultSubject.asObserver()
        self.photosWithStatus = self.photosWithStatusSubject.asObservable()
        self.phFetchResultSubject.unwrap()
            .map { [weak self] fetchResult in
                //return self?.loadPhotosWithStatus(pHFetchResult: fetchResult)?? []
            }.subscribe(onNext: { [weak self] photosWithStatus in
                //self?.photosWithStatusSubject.onNext(photosWithStatus)
            }).disposed(by: disposeBag)
    }
    
    func removeFile(identifier: String, isVideo: Bool) {
        if self.statusDictionary[identifier]?.status == nil {
            return // 저장x -> return
        }
        
        if self.statusDictionary[identifier]?.status != .unSelected {
            
        }
    }
    
    func addNewImage(data: Data) {
        if let image = UIImage(data: data) {
            self.addNewImage(image: image, data: data)
        }
    }
    
    func addNewImageAfterCompress(image: UIImage) {
        if let imageData = AttachmentInputUtil.compressImage(image: image, photoQuality: self.configuration.photoQuality) {
            self.addNewImage(image: image, data: imageData)
        }
    }
    
    func isSelectExceed() -> Bool {
        if self.configuration.maxSelect <= self.statusDictionary.filter({ $0.value.status == .selected }).count {
            Toast.show("최대 \(self.configuration.maxSelect)개까지 선택할 수 있습니다.", on: .visibleView)
            return true
        } else {
            return false
        }
    }
    
    func isVideoSelectExceed() -> Bool {
        if self.configuration.maxVideo <= self.configuration.currentVideoCount {
            Toast.show("동영상은 최대 \(self.configuration.maxVideo)개까지 선택할 수 있습니다.", on: .visibleView)
            return true
        } else{
            return false
        }
    }
    
    private func addNewImage(image: UIImage, data: Data) {
        let fileSize = Int64(data.count)
        if self.configuration.fileSizeLimit <= fileSize {
            self.onError(error: AttachmentInputError.overLimitSize)
            return
        }
        let fileName = "image " + AttachmentInputUtil.datetimeForDisplay(from: Date()) + ".jpeg"
        let id = NSUUID().uuidString
        if let thumbnail = AttachmentInputUtil.resizeFill(image: image, size: AttachmentInputViewLogic.PHOTO_TILE_THUMBNAIL_SIZE) {
            self.inputImage(fileURL: URL(string: "")!, image: image, fileName: fileName, fileSize: fileSize, fileId: id, imageThumbnail: image)
        } else {
            self.inputImage(fileURL: URL(string: "")!, image: image, fileName: fileName, fileSize: fileSize, fileId: id, imageThumbnail: nil)
        }
    }
    
    func addNewVideo(url: URL) {
        let fileSize = AttachmentInputUtil.getSizeFromFileUrl(fileUrl: url) ?? 0
        if self.configuration.fileSizeLimit <= fileSize {
            self.onError(error: AttachmentInputError.overLimitSize)
            return
        }
        let fileName = "video " + AttachmentInputUtil.datetimeForDisplay(from: Date()) + ".MOV"
        let id = NSUUID().uuidString
        
        getThumbnailImageFromVideoUrl(url: url) { image in
            self.inputMedia(fileURL: url, fileName: fileName, fileSize: fileSize, fileId: id, imageThumbnail: image, isVideo: true)
        }
    }
    
    func onSelectPickerMedia(phAsset: PHAsset, videoUrl: URL?) {
        if let photo = AttachmentInputPhoto(asset: phAsset, uploadSizeLimit: self.configuration.fileSizeLimit, imageManager: self.imageManager) {
            photo.initializeIfNeed(loadThumbnail: false)
            _ = photo.properties.take(1).subscribe(onNext: { [weak self] properties in
                if properties.exceededSizeLimit {
                    self?.onError(error: AttachmentInputError.overLimitSize)
                    return
                }
                
                if let status = self?.statusDictionary[photo.identifier] {
                    if status.status != .unSelected {
                        return
                    }
                    status.input.onNext(.selected)
                    if let videoUrl = videoUrl {
                        let fileSize = AttachmentInputUtil.getSizeFromFileUrl(fileUrl: videoUrl) ?? 0
                        self?.inputMedia(fileURL: videoUrl, fileName: properties.fileName, fileSize: fileSize, fileId: photo.identifier, imageThumbnail: nil, isVideo: true)
                    } else {
                        self?.addImageAfterFetchAndCompress(photo: photo, fileName: properties.fileName, status: status)
                    }
                } else {
                    self?.statusDictionary[photo.identifier] = AttachmentInputPhotoStatus()
                    self?.statusDictionary[photo.identifier]?.input.onNext(.selected)
                }
            }, onError: { [weak self] error in
                self?.onError(error: error)
            })
        }
    }
    
    func onTapPhotoCell(photo: AttachmentInputPhoto, selectIndex: AttachmentInputPhotoSelectIndex) {
        _ = photo.properties.take(1).subscribe(onNext: { [weak self] properties in
            if properties.exceededSizeLimit {
                self?.onError(error: AttachmentInputError.overLimitSize)
                return
            }
            if let status = self?.statusDictionary[photo.identifier] {
                // 선택 -> 선택해제
                if status.status == .selected {
                    self?.removeFile(fileId: photo.identifier)
                    
                    // 현재 선택된 인덱스 보다 크면 하나씩 줄여주기
                    let search = self!.selectIndex.filter({ $0.value.index >= selectIndex.index })
                    for i in search {
                        i.value.input.onNext(i.value.index - 1)
                    }
                    
                    status.input.onNext(.unSelected)
                    return
                }
            }
        }, onError: { [weak self] error in
            self?.onError(error: error)
        })
    }
    
    func addImageAfterFetchAndCompress(photo: AttachmentInputPhoto, fileName: String, status: AttachmentInputPhotoStatus) {
        
    }
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?) -> Void)) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumbnailTime = CMTimeMake(value: 2, timescale: 1)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
                let thumbNailImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbNailImage)
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
}

extension AttachmentInputViewLogic {
    
    private func inputImage(fileURL: URL, image: UIImage, fileName: String, fileSize: Int64, fileId: String, imageThumbnail: UIImage?) {
        DispatchQueue.main.async {
            self.delegate?.inputImage(fileURL: fileURL, image: image, fileName: fileName, fileSize: fileSize, fileId: fileId, imageThumbnail: imageThumbnail)
        }
    }
    
    private func inputMedia(fileURL: URL, fileName: String, fileSize: Int64, fileId: String, imageThumbnail: UIImage?, isVideo: Bool) {
        DispatchQueue.main.async {
            self.delegate?.inputMedia(fileURL: fileURL, fileName: fileName, fileSize: fileSize, fileId: fileId, imageThumbnail: imageThumbnail, isVideo: isVideo)
        }
    }
    
    private func removeFile(fileId: String) {
        DispatchQueue.main.async {
            self.delegate?.removeFile(fileId: fileId)
        }
    }
    
    func onError(error: Error) {
        DispatchQueue.main.async {
            self.delegate?.onError(error: error)
        }
    }
}
