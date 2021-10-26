//
//  AttachmentInputView.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/25.
//

import UIKit
import RxDataSources
import RxSwift
import Photos
import MobileCoreServices

enum GalleryType {
    case photo
    case video
    case all
    case none
}

class AttachmentInputView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    private let bag = DisposeBag()
    private var logic: AttachmentInputViewLogic?
    private var initialized = false
    
    
    
    static func createAttachmentInputView(configuration: AttachmentInputConfiguration) -> AttachmentInputView {
        
        return AttachmentInputView()
    }
}
