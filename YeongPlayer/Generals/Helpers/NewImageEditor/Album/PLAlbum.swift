//
//  PLAlbum.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/07.
//

import UIKit
import Photos

struct PLAlbum {
    
    var thumbnail: UIImage?             // 앨범 썸네일
    var title: String = ""              // 앨범 제목
    var numberOfItems: Int = 0          // 앨범 속 파일 개수
    var collection: PHAssetCollection?  // 앨범 종류 타입
}
