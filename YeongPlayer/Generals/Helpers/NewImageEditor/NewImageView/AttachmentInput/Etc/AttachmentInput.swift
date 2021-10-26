//
//  AttachmentInput.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/22.
//

import Foundation
import Photos
import UIKit

public class AttachmentInput {
    
    public static let defaultConfiguration = AttachmentInputConfiguration()
    private let attachmentInputView: AttachmentInputView
    
    public var view: UIView {
        get {
            self.attachmentInputView
        }
    }
    
    public var collectionView: UICollectionView {
        get {
            return self.attachmentInputView.collectionView
        }
    }
    
//    public var delegate: AttachmentInputDelegate? {
//        get {
//            return self.attachmentInputView.delegate
//        }
//        set {
//            self.attachmentInputView.delegate = newValue
//        }
//    }
    
    public init(configuration: AttachmentInputConfiguration = AttachmentInput.defaultConfiguration) {
        self.attachmentInputView = AttachmentInputView.createAttachmentInputView(configuration: configuration)
    }
    
    func changeImage(asset: PHAssetCollection) {
        
    }
}
