//
//  test1.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/12.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources
import MobileCoreServices
import Photos

enum Gallerytype {
    case photo
    case video
    case all
    case none
}

class AttachmentInputView: UIView {
    
    fileprivate enum SectionType {
        case PhotoListSection(items: [SectionItemType])
    }
    
    fileprivate enum SectionItemType {
        case ImagePickerItem
        case PhotoListItem(photo: AttachmentInputPhoto? = nil, status: AttachmentInputPhotoStatus = .init(), selectIndex: AttachmentInputPhotoSelectIndex)
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionType>!
    private let bag = DisposeBag()
    private var logic: AttachmentInputViewLogic?
    private var initialized = false
    
    private var photoDictionary: [AttachmentInputPhoto] = []
    
    public var delegate: AttachmentInputDelegate? {
        get {
            return self.logic?.delegate
        }
        set {
            self.logic?.delegate = newValue
        }
    }
    
    private var configuration: AttachmentInputConfiguration!
    
    static func createAttachmentInputView(configuration: AttachmentInputConfiguration) -> AttachmentInputView {
        
        let attachmentInputView = Bundle(for: self).loadNibNamed("AttachmentInputView", owner: self, options: nil)?.first as! AttachmentInputView
        attachmentInputView.configuration = configuration
        attachmentInputView.logic = AttachmentInputViewLogic(configuration: configuration)
        return attachmentInputView
    }
    
    func initializeIfNeed() {
        guard !self.initialized else { return }
        self.initialized = true
        
        PHPhotoLibrary.shared().register(self)
        self.initializeCollectionView()
    }
    
    func removeFile(identifier: String, isVideo: Bool) {
        self.logic?.removeFile(identifier: identifier, isVideo: isVideo)
    }
    
    private func initializeCollectionView() {
        let bundle = Bundle(for: self.classForCoder)
        self.collectionView.register(UINib(nibName: "ImagePickerCell", bundle: bundle), forCellWithReuseIdentifier: "ImagePickerCell")
        self.collectionView.register(UINib(nibName: "PhotoAlbumCell", bundle: bundle), forCellWithReuseIdentifier: "PhotoAlbumCell")
        
        // dataSource
        self.dataSource = RxCollectionViewSectionedReloadDataSource<SectionType>(configureCell: { (_, _, indexPath, item) -> UICollectionViewCell in
            switch item {
            case .ImagePickerItem:
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePickerCell", for: indexPath) as! ImagePickerCell
                
                cell.delegate = self
                cell.galleryType = self.configuration.galleryType
                cell.setup()
                cell.jsonData = self.configuration.jsonData
                
                return cell
            
            case .PhotoListItem(let photo, let status, let selectIndex):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCell", for: indexPath) as! PhotoAlbumCell
                if status.status == .selected {
                    // 사진 셀 최대 선택 개수 체크
                    if self.configuration.maxSelect >= 10 {
                        cell.setup(photo: photo!, status: status, selectIndex: selectIndex)
                        return cell
                    }
                    
                    if self.logic!.isCamera == true {
                        self.logic?.statusDictionary[photo!.identifier]?.input.onNext(.selected)
                    }
                } else {
                    
                }
                
                cell.setup(photo: photo!, status: status, selectIndex: selectIndex)
                
                return cell
            }
        })
        
        //self.requestauthorizationIfNeeded
        self.requestAuthorizationIfNeeded(completion: { [weak self] authorized in
            if authorized {
                self?.fetchAssets(asset: nil)
            }
        })
        
        // show CollectionView
        self.collectionView.delegate = self
        
        // add picker control and camera section
        var ret = [SectionType]()
        ret.append(SectionType.PhotoListSection(items: [SectionItemType.ImagePickerItem]))
        let controllerObservable = Observable.just(ret)
        
        Observable<[SectionType]>.combineLatest(controllerObservable, self.logic!.photosWithStatus) { (controller, output) in
            // ( _: SectionType - controllerObservable, _: SectionItemType(photo, status, selectIndex) ) in
            
            _ = output.map({ output in
                self.photoDictionary.append(output.photo)
            })
            var photoItems = output.map({ ouput in
                return SectionItemType.PhotoListItem(photo: ouput.photo, status: ouput.status, selectIndex: ouput.selectIndex)
            })
            photoItems.reverse()
            photoItems.append(contentsOf: [SectionItemType.ImagePickerItem])
            photoItems.reverse()
            
            return [SectionType.PhotoListSection(items: photoItems)]
        }.bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
        .disposed(by: self.bag)
        
        // onTapPhotoCell
        self.collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                
                if let item = self?.dataSource.sectionModels[indexPath.section].items[indexPath.item] {
                    switch item {
                    case .PhotoListItem(let photo, let status, let selectIndex):
                        if status.status == .selected { // 선택된 셀 해제하려고 눌렀을 떄
                            if photo!.isVideo { // 비디오를 선택했을 경우
                                self!.configuration.currentVideoCount -= 1
                            }
                        } else {
                            
                        }
                        self?.logic?.onTapPhotoCell(photo: photo!, selectIndex: selectIndex)
                    default:
                        // 아무것도 안하기
                        break
                    }
                }
            }).disposed(by: self.bag)
    }
    
    
    private func requestAuthorizationIfNeeded(completion: @escaping (_ authorized: Bool) -> Void) {
        let status: PHAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { status in
                    completion(status == .authorized || status == .limited)
                })
            } else {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    completion(status == .authorized)
                })
            }
        case .restricted, .denied:
            completion(false)
        case .authorized, .limited:
            completion(true)
        @unknown default:
            fatalError()
        }
    }
    
    // 앨범 사진 세팅, 가져오기 Fetch
    func fetchAssets(asset: PHAssetCollection?) {
        DispatchQueue.main.async {
            // 사진 추가
            let photosOptions = PHFetchOptions()
            photosOptions.fetchLimit = self.configuration.photoCellCountLimit
            
            if self.configuration.galleryType == .all {
                photosOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d && (duration > %f && duration < %f)",
                                                      PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue, self.configuration.minVideoTime, self.configuration.maxVideoTime + 0.99)
                // 이미지, 비디오 (최소 초과 최대 미만)
            } else if self.configuration.galleryType == .video {
                photosOptions.predicate = NSPredicate(format: "mediaType == %d && (duration > %f && duration < %f)",
                                                      PHAssetMediaType.video.rawValue, self.configuration.minVideoTime, self.configuration.maxVideoTime + 0.99)
                // 비디오 최소 초과 최대 미만
            } else {
                photosOptions.predicate = NSPredicate(format: "mediaType == %d",
                                                      PHAssetMediaType.image.rawValue)
                // 이미지만
            }
            
            photosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            if asset == nil {
                self.logic?.pHFetchResultObserver.onNext(PHAsset.fetchAssets(with: photosOptions))
            } else {
                self.logic?.pHFetchResultObserver.onNext(PHAsset.fetchKeyAssets(in: asset!, options: photosOptions))
            }
        }
    }
    
    
    
}

extension AttachmentInputView: ImagePickerCellDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 두번 누르면 여러번 호출 되니까 방지하자
        if picker.isBeingDismissed { return }
        
        if let phAsset = info[.phAsset] as? PHAsset {
            // 카메라 -> 앨범 선택시
            if let mediaType = info[.mediaType] as? String {
                if mediaType == kUTTypeImage as String {
                    self.logic?.onSelectPickerMedia(phAsset: phAsset, videoUrl: nil)
                } else if mediaType == kUTTypeMovie as String {
                    if let mediaUrl = info[.mediaURL] as? URL {
                        self.logic?.onSelectPickerMedia(phAsset: phAsset, videoUrl: mediaUrl)
                    }
                }
            }
        } else {
            // 사진 찍었을 때
            if let image = info[.originalImage] as? UIImage {
                self.logic?.isCamera = true
            } else if let videoUrl = info[.mediaURL] as? URL {
                self.logic?.addNewVideo(url: videoUrl)
            }
        }
        DispatchQueue.main.async {
            picker.dismiss(animated: true, completion: nil)
            self.delegate?.imagePickerControllerDidDismiss()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        DispatchQueue.main.async {
            picker.dismiss(animated: true, completion: nil)
            self.delegate?.imagePickerControllerDidDismiss()
        }
    }
    
    var videoQuality: UIImagePickerController.QualityType {
        return self.configuration.videoQuality
    }
    
    func isSelectExceed() -> Bool {
        if self.logic!.isSelectExceed() {
            // 그냥 isSelecteExceed() 였다면 순환참조 되었다...?
            return true
        } else {
            return false
        }
    }
    
    func isVideoSelectExceed() -> Bool {
        if self.logic!.isVideoSelectExceed() {
            return true
        } else {
            return false
        }
    }
    
    
}



extension AttachmentInputView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.frame.width / 3.04
        return CGSize(width: width, height: width)
    }
}

extension AttachmentInputView.SectionType: SectionModelType {
    typealias Item = AttachmentInputView.SectionItemType
    
    var items: [AttachmentInputView.SectionItemType] {
        switch self {
        case .PhotoListSection(items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: AttachmentInputView.SectionType, items: [Item]) {
        switch original {
        case .PhotoListSection:
            self = .PhotoListSection(items: items)
        }
    }
}

extension AttachmentInputView: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            if let _ = App.module.presenter.visibleViewController as? PhotoViewController {
                
                if let photosFetchResult = self.logic?.pHFetchResult, let changeDetails = changeInstance.changeDetails(for: photosFetchResult) {
                    
                    self.logic?.isCamera = true
                    self.logic?.pHFetchResultObserver.onNext(changeDetails.fetchResultAfterChanges)
                }
            } else {
                
            }
        }
        // main thread end
    }
    // func end
}
