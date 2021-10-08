//
//  PhotoData.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/05.
//

import Foundation
import UIKit

struct PhotoData: Equatable {
    var fileURL: URL?
    var image: UIImage?
    var fileName: String
    var fileSize: String
    var fileId: String
    var isVideo: Bool
}
