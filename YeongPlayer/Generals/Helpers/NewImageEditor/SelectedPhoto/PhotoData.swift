//
//  PhotoData.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/05.
//

import Foundation
import UIKit

struct PhotoData: Equatable {
    // 파일 주소
    var fileURL: URL?
    // 썸네일 이미지
    var image: UIImage?
    // 파일 이름 : 서버에서 구분?
    var fileName: String
    // 파일 크기 :
    var fileSize: String
    // 파일 식별자?
    var fileId: String
    // 이미지인지 비디오인지 판단
    var isVideo: Bool
}
