//
//  test1.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/12.
//

import Foundation
import UIKit

enum Gallerytype {
    case photo
    case video
    case all
    case none
}

class AttachmentInputView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!
}
