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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    private let bag = DisposeBag()
    private var logic: AttachmentInputViewLogic?
    
    private var initialized = false
    
    
    public var delegate: AttachmentInputDelegate? {
        get {
            return self.logic?.delegate
        }
        set {
            self.logic?.delegate = newValue
        }
    }
    
    static func createAttachmentInputView(configuration: AttachmentInputConfiguration) -> AttachmentInputView {
        
        let attachmentInputView = Bundle(for: self).loadNibNamed("AttachmentInputView", owner: self, options: nil)?.first as! AttachmentInputView
        
        return attachmentInputView
    }
    
    func initializeIfNeed() {
        
    }
    
    func removeFile(identifier: String, isVideo: Bool) {
        self.logic?.removeFile(identifier: identifier, isVideo: isVideo)
    }
}
