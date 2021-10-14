
import Foundation
import Photos
import RxSwift

class AttachmentInputViewLogic {
    private static let PHOTO_TILE_THUMBNAIL_LENGTH: CGFloat = 128
    static let PHOTO_TILE_THUMBNAIL_SIZE = CGSize(width: PHOTO_TILE_THUMBNAIL_LENGTH, height: PHOTO_TILE_THUMBNAIL_LENGTH)
    var isCamera = false
    
    private let bag = DisposeBag()
    // imageManager는 처음사용시에 권한 설정을 표시하기 때문에 lazy로
    lazy public var imageManager = PHImageManager()
    private let configuration: AttachmentInputConfiguration
    private let pHFetchResultSubject = BehaviorSubject<PHFetchResult<PHAsset>?>(value: nil)
    private let photosWithStatusSubject = BehaviorSubject<[(photo: AttachmentInputPhoto,
                                                            status: AttachmentInputPhotoStatus,
                                                            selectIndex: AttachmentInputPhotoSelectIndex)]>(value: [])
    private let fileManager = FileManager.default
    
    /// Status 와 Photos 는 별도로 관리
    /// 기기의 사진이 업데이트 될 때마다 사진이 변경되는데
    /// 파일을 변경할 때는 상태가 업데이트 되지 않음
    public var statusDictionary: Dictionary<String, AttachmentInputPhotoStatus> = [:]
    public var selectIndex: Dictionary<String, AttachmentInputPhotoSelectIndex> = [:]
    
    weak var delegate: AttachmentInputDelegate?
    
    // input
    let pHFetchResultObserver: AnyObserver<PHFetchResult<PHAsset>?>
    // output
    var pHFetchResult: PHFetchResult<PHAsset>? {
        return self.pHFetchResultSubject.value(nil)
    }
    var photosWithStatus: Observable<[(photo: AttachmentInputPhoto,
                                       status: AttachmentInputPhotoStatus,
                                       selectIndex: AttachmentInputPhotoSelectIndex)]>
    
    
    init(configuration: AttachmentInputConfiguration) {
        self.configuration = configuration
        self.pHFetchResultObserver = self.pHFetchResultSubject.asObserver()
        self.photosWithStatus = self.photosWithStatusSubject.asObservable()
        
        self.pHFetchResultSubject.unwrap()
            .map { [weak self] fetchResult in
                return self?.loadPhotosWithStatus(pHFetchResult: fetchResult) ?? []
            }.subscribe(onNext: { [weak self] photosWithStatus in
                self?.photosWithStatusSubject.onNext(photosWithStatus)
            }).disposed(by: self.bag)
    }
    
    func removeFile(identifier: String, isVideo: Bool) {
        // StatusDictionary<identifier : PhotoStatus>
        if self.statusDictionary[identifier]?.status == nil {
            return
        }
        
        if !(self.statusDictionary[identifier]?.status == .unSelected) {
            let search = self.selectIndex.filter({ $0.value.index >= self.selectIndex[identifier]!.index })
            for i in search {
                i.value.input.onNext(i.value.index - 1)
            }
            
            if isVideo {
                self.configuration.currentVideoCount -= 1
            }
            self.statusDictionary[identifier]?.input.onNext(.unSelected)
        }
    }
    
    
    func addNewImage(data: Data) {
        if let image = UIImage(data: data) {
            self.addNewImage(image: image, data: data)
        }
    }
    
    func addnewImageAfterCompress(image: UIImage) {
        if let imageData = AttachmentInputUtil.compressImage(image: image, photoQuality: self.configuration.photoQuality) {
            self.addNewImage(image: image, data: imageData)
        }
    }
    
    func isSelectExceed() -> Bool {
        if self.configuration.maxSelect <= self.statusDictionary.filter({ $0.value.status == .selected }).count {
            Toast.show("최대 \(self.configuration.maxSelect)개 까지 선택할 수 있습니다.", on: .visibleView)
            return true
        } else {
            return false
        }
    }
    
    func isVideoSelectExceed() -> Bool {
        if self.configuration.maxVideo <= self.configuration.currentVideoCount {
            Toast.show("동영상은 최대 \(self.configuration.maxVideo)개까지 선택할 수 있습니다.", on: .visibleView)
            return true
        } else {
            return false
        }
    }
    
    // 파일이름, 사진 추가
    private func addNewImage(image: UIImage, data: Data) {
        // 이미지 최대 용량 이하로 거르기
        let fileSize = Int64(data.count)
        
        if self.configuration.fileSizeLimit <= fileSize {
            // config에 있는 파일 최대용량보다 크면 에러 전달과 return
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
    
    // 파일이름, 비디오 추가
    func addNewVideo(url: URL) {
        // Int64?
        let fileSize = AttachmentInputUtil.getSizeFromFileUrl(fileUrl: url) ?? 0
        if self.configuration.fileSizeLimit <= fileSize {
            self.onError(error: AttachmentInputError.overLimitSize)
            return
        }
        
        // "video20211014083810.mov" ???
        let fileName = "video " + AttachmentInputUtil.datetimeForDisplay(from: Date()) + ".MOV"
        let id = NSUUID().uuidString
        
        getThumbnailImageFromVideoUrl(url: url) { image in
            self.inputMedia(fileURL: url, imageThumbnail: image, fileName: fileName, fileSize: fileSize, fileId: id, isVideo: true)
        }
    }
    
    // ImagePickerController 에서 가져온 사진을 선택할 때
    func onSelectPickerMedia(phAsset: PHAsset, videoUrl: URL?) {
        // 사진이 있을 때
        if let photo = AttachmentInputPhoto(asset: phAsset, uploadSizeLimit: self.configuration.fileSizeLimit, imageManager: self.imageManager) {
            
            photo.initializeIfNeed(loadThumbnail: false)
            _ = photo.properties.take(1).subscribe(onNext: { [weak self] properties in
                // 파일 용량 제한
                if properties.exceededSizeLimit {
                    self?.onError(error: AttachmentInputError.overLimitSize)
                    return
                }
                
                // 사진의 상태 파악
                if let status = self?.statusDictionary[photo.identifier] {
                    //
                    if status.status != .unSelected {
                        // 미선택 상태일 때 아무것도 하지 않음
                        return
                    }
                    
                    // ---- 사진의 상태가 선택일 경우 -----
                    status.input.onNext(.selected)
                    if let videoUrl = videoUrl {
                        // 동영상은 imagePickerController 에서 불러오는 것을 전제로 압축하기 때문에 따로 압축할 필요가 없다
                        let fileSize = AttachmentInputUtil.getSizeFromFileUrl(fileUrl: videoUrl) ?? 0
                        self?.inputMedia(fileURL: videoUrl, imageThumbnail: nil, fileName: properties.filename, fileSize: fileSize, fileId: photo.identifier, isVideo: true)
                    } else {
                        self?.addImageAfterFetchAndCompress(photo: photo, fileName: properties.filename, status: status)
                    }
                } else {
                    // 저장된 상태가 없을 때 새로 만들고 선택으로 지정해주기
                    self?.statusDictionary[photo.identifier] = AttachmentInputPhotoStatus()
                    self?.statusDictionary[photo.identifier]?.input.onNext(.selected)
                }
            }, onError: { [weak self] error in
                self?.onError(error: error)
            })
        }
    }
    
    // 사진 셀 탭했을 때
    func onTapPhotoCell(photo: AttachmentInputPhoto, selectIndex: AttachmentInputPhotoSelectIndex) {
        _ = photo.properties.take(1).subscribe(onNext: { [weak self] properties in
            
            // 파일 용량 제한
            if properties.exceededSizeLimit {
                self?.onError(error: AttachmentInputError.overLimitSize)
                return
            }
            
            // 사진의 상태가 있을 때: 상태가 없으면 아무것도 안함
            if let status = self?.statusDictionary[photo.identifier] {
                // 1. 선택한 것 누를 때 처리
                // 2. 최대 개수 이상 선택 방지 처리
                
                // 이미 선택된 경우 삭제 -> 선택리스트에서 지워진다
                if status.status == .selected {
                    self?.removeFile(fileId: photo.identifier)
                    
                    // 현재 선택된 인덱스 보다 크면 하나씩 줄여주기 : 하나가 삭제되니까 인덱스도 하나 줄어들기
                    // let $0: (key: String, value: AttachmentInputPhotoSelectIndex)
                    let search = self!.selectIndex.filter({ $0.value.index >= selectIndex.index })
                    for i in search {
                        i.value.input.onNext(i.value.index - 1)
                    }
                    
                    // 삭제 했으니까 상태 미선택으로 바꿔주기
                    status.input.onNext(.unSelected)
                    return
                } else {
                    // 최대 개수 선택했는지 체크
                    if self!.isSelectExceed() { return }
                }
                
                // 미선택이 아닐 경우 처리 방지 -> 미선택일 때만 처리 할 수 있게
                // 미선택이 아닐 경우 : .downloading, .loading, .compressing, .selected( 위에서 이미 처리함 )
                if status.status != .unSelected { return }
                
                if photo.isVideo {
                    // 동영상일 때 최대 선택개수 넘는지 체크
                    if self!.isVideoSelectExceed() { return }
                    
                    self?.addVideoAfterFetchAndCompress(photo: photo, fileName: properties.filename, status: status)
                } else {
                    // 사진일 때
                    self?.addImageAfterFetchAndCompress(photo: photo, fileName: properties.filename, status: status)
                }
            }
        }, onError: { [weak self] error in
            self?.onError(error: error)
        })
    }
    
    
    // 비디오 추가 후 페치 & 압축 : 사진, 이름, 상태
    private func addVideoAfterFetchAndCompress(photo: AttachmentInputPhoto, fileName: String, status: AttachmentInputPhotoStatus) {
        status.input.onNext(.loading)
        
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.version = .original
        options.progressHandler = { [weak self] (progress, error, stop, info) in
            if let error = error {
                self?.onError(error: error)
                status.input.onNext(.unSelected)
            } else {
                status.input.onNext(.downloading)
            }
        }
        
        // 동영상 썸네일 이미지 만들기
        let imageOptions = PHImageRequestOptions()
        let preferredImageSize = CGSize(width: 400, height: 400)
        imageOptions.isSynchronous = false
        imageOptions.isNetworkAccessAllowed = true
        imageOptions.deliveryMode = .highQualityFormat
        imageOptions.version = .original
        imageOptions.resizeMode = .fast
        
        let cachingManager = PHCachingImageManager()
        DispatchQueue.main.async {
            cachingManager.requestImage(for: photo.asset, targetSize: preferredImageSize, contentMode: .aspectFill, options: imageOptions, resultHandler: { (image, _) in
                
                cachingManager.requestAVAsset(forVideo: photo.asset, options: options, resultHandler: { (avAsset, avAudioMix, info_) in
                    
                    let fileUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(NSUUID().uuidString + ".mp4")
                    let urlAsset = avAsset as! AVURLAsset
                    let fileName = AttachmentInputUtil.addFilenameExtension(fileName: fileName, extensionString: "MOV")
                    let fileSize = AttachmentInputUtil.getSizeFromFileUrl(fileUrl: fileUrl) ?? 0
                    
                    DispatchQueue.main.async {
                        if self.isVideoSelectExceed() {
                            // 비디오 선택 개수 초과돼서 선택 풀어주기
                            status.input.onNext(.unSelected)
                            return
                        } else {
                            // 동영상 추가해주고 선택했다고 알려주기
                            self.inputMedia(fileURL: urlAsset.url, imageThumbnail: image, fileName: fileName, fileSize: fileSize, fileId: photo.identifier, isVideo: true)
                            status.input.onNext(.selected)
                            // 선택하면 동영상 선택 개수 +1, 선택 인덱스 올려주기
                            self.configuration.currentVideoCount += 1
                            self.selectIndex[photo.identifier]?.input
                                .onNext(self.statusDictionary.filter({ $0.value.status == .selected }).count)
                        }
                    }
                })
            })
        }
    }
    
    private func addImageAfterFetchAndCompress(photo: AttachmentInputPhoto, fileName: String, status: AttachmentInputPhotoStatus) {
        // 로딩중으로 바꿔주기
        status.input.onNext(.loading)
        
        let imageOptions = PHImageRequestOptions()
        let preferredImageSize = CGSize(width: 800, height: 800)
        imageOptions.isSynchronous = true
        imageOptions.isNetworkAccessAllowed = true
        imageOptions.deliveryMode = .highQualityFormat
        imageOptions.version = .original
        imageOptions.resizeMode = .fast
        
        imageOptions.progressHandler = { [weak self] (progress, error, stop, info) in
            log.d("progress: \(progress)")
            if let error = error {
                self?.onError(error: error)
                status.input.onNext(.unSelected)
            } else {
                status.input.onNext(.downloading)
            }
        }
        
        let cachingManager = PHCachingImageManager()
        cachingManager.requestImage(for: photo.asset, targetSize: preferredImageSize, contentMode: .aspectFill, options: imageOptions, resultHandler: { (image, _) in
            photo.asset.getURL { responseURL in
                guard let fileURL = responseURL else {
                    return
                }
                
                // 이미 최대 선택개수인데 선택되는 것 방지
                if self.isSelectExceed() {
                    return
                }
                
                // 선택했다고 전해주기, 이미지 추가하기, 선택 인덱스 올려주기
                status.input.onNext(.selected)
                self.inputImage(fileURL: fileURL, image: image ?? UIImage(), fileName: "", fileSize: 0, fileId: photo.identifier, imageThumbnail: image)
                self.selectIndex[photo.identifier]?.input
                    .onNext(self.statusDictionary.filter({ $0.value.status == .selected }).count)
            }
        })
    }
    
    public func loadPhotosWithStatus(pHFetchResult: PHFetchResult<PHAsset>) -> [(AttachmentInputPhoto,
                                                                                 AttachmentInputPhotoStatus,
                                                                                 AttachmentInputPhotoSelectIndex)] {
        var items = [(AttachmentInputPhoto, AttachmentInputPhotoStatus, AttachmentInputPhotoSelectIndex)]()
        
        if 0 < pHFetchResult.count {
            
            let indexSet = IndexSet(integersIn: 0..<pHFetchResult.count)
            let photosItems = pHFetchResult.objects(at: indexSet)
            photosItems.forEach({ asset in
                if let photo = AttachmentInputPhoto(asset: asset,
                                                    uploadSizeLimit: self.configuration.fileSizeLimit,
                                                    imageManager: self.imageManager) {
                    // 사진은 매번 새롭게 만들지만
                    // 상태가 이미 있을 경우 재사용하기
                    // statusDictionary: Dictionary<String, AttachmentInputPhotoStatus>
                    if self.statusDictionary[asset.localIdentifier] == nil {
                        if isCamera == true {
                            self.statusDictionary[asset.localIdentifier] = AttachmentInputPhotoStatus()
                            self.statusDictionary[asset.localIdentifier]?.input.onNext(.selected)
                        } else {
                            self.statusDictionary[asset.localIdentifier] = AttachmentInputPhotoStatus()
                        }
                    }
                    
                    // selectIndex: Dictionary<String, AttachmentInputPhotoSelectIndex>
                    if self.selectIndex[asset.localIdentifier] == nil {
                        if isCamera == true {
                            self.selectIndex[asset.localIdentifier] = AttachmentInputPhotoSelectIndex()
                            
                            if photo.isVideo {
                                // 카메라로 비디오 촬영했으면
                                // configuration.currentVideoCount += 1
                            }
                            self.selectIndex[photo.identifier]?.input
                                .onNext(self.statusDictionary.filter({ $0.value.status == .selected }).count)
                            
                            let manager = PHImageManager.default()
                            let option = PHImageRequestOptions()
                            option.isSynchronous = true
                            manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: option, resultHandler: { (image, info) -> Void in
                                if photo.isVideo {
                                    // self.addVideoAfterFetchAndCompress
                                } else {
                                    // self.addImageAfterFetchAndCompress
                                }
                            })
                        } else {
                            self.selectIndex[asset.localIdentifier] = AttachmentInputPhotoSelectIndex()
                        }
                    }
                    isCamera = false
                    // items: (Photo, Status, SelectIndex)
                    items.append((photo,
                                  self.statusDictionary[asset.localIdentifier]!,
                                  self.selectIndex[asset.localIdentifier]!))
                }
            })
        }
        
        return items
    }
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?) -> Void)) {
        DispatchQueue.global().async { // 1
            let asset = AVAsset(url: url)  // 2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) // 3
            avAssetImageGenerator.appliesPreferredTrackTransform = true // 4
            let thumbnailTime = CMTimeMake(value: 2, timescale: 1) // 5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil) // 6
                let thumbNailImage = UIImage(cgImage: cgThumbImage) // 7
                DispatchQueue.main.async { // 8
                    completion(thumbNailImage) // 9
                }
            } catch {
                print(error.localizedDescription) // 10
                DispatchQueue.main.async {
                    completion(nil) // 11
                }
            }
        }
    }
}

// Extension : 메인스레드에서 실행할 콜백
extension AttachmentInputViewLogic {
    private func inputImage(fileURL: URL, image: UIImage, fileName: String, fileSize: Int64, fileId: String, imageThumbnail: UIImage?) {
        DispatchQueue.main.async {
            self.delegate?.inputImage(fileURL: fileURL, image: image, fileName: fileName, fileSize: fileSize, fileId: fileId, imageThumbnail: imageThumbnail)
        }
    }
    
    private func inputMedia(fileURL: URL, imageThumbnail: UIImage?, fileName: String, fileSize: Int64, fileId: String, isVideo: Bool) {
        DispatchQueue.main.async {
            self.delegate?.inputMedia(fileURL: fileURL, imageThumbnail: imageThumbnail, fileName: fileName, fileSize: fileSize, fileId: fileId, isVideo: isVideo)
        }
    }
    
    private func removeFile(fileId: String) {
        DispatchQueue.main.async {
            self.delegate?.removeFile(fileId: fileId)
        }
    }
    
    private func onError(error: Error) {
        DispatchQueue.main.async {
            self.delegate?.onError(error: error)
        }
    }
}
