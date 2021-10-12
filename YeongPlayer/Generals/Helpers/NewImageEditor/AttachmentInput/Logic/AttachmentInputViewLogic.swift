
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
        
    }
    
    public func loadPhotosWithStatus(pHFetchResult: PHFetchResult<PHAsset>) -> [(AttachmentInputPhoto,
                                                                                 AttachmentInputPhotoStatus,
                                                                                 AttachmentInputPhotoSelectIndex)] {
        var items = [(AttachmentInputPhoto, AttachmentInputPhotoStatus, AttachmentInputPhotoSelectIndex)]()
        
        return items
    }
}
