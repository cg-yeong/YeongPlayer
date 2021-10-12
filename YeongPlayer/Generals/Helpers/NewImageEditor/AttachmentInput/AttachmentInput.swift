//
//  AttachmentInput.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/12.
//

import UIKit
import Photos

public class AttachmentInput {
    
    public static let defaultConfiguration = AttachmentInputConfiguration()
    private let attachmentInputView: AttachmentInputView
    
    public var view: UIView {
        get {
            self.attachmentInputView.initializeIfNeed()
            return self.attachmentInputView
        }
    }
    
    public var collectionView: UICollectionView {
        get {
            return self.attachmentInputView.collectionView
        }
    }
    
    public var delegate: AttachmentInputDelegate? {
        get {
            return self.attachmentInputView.delegate
        }
        set {
            return self.attachmentInputView.delegate = newValue
        }
    }
    
    public init(configuration: AttachmentInputConfiguration = AttachmentInput.defaultConfiguration) {
        self.attachmentInputView = AttachmentInputView.createAttachmentInputView(configuration: configuration)
    }
    
    public func removeFile(identifier: String, isVideo: Bool) {
        self.attachmentInputView
    }
    
    public func changeImage(asset: PHAssetCollection) {
        self.attachmentInputView
    }
}
