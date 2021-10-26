//
//  AttachmentInputDelegate.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/25.
//

import UIKit

public protocol AttachmentInputDelegate: AnyObject {
    func inputImage(fileURL: URL, image: UIImage, fileName: String, fileSize: Int64, fileId: String, imageThumbnail: UIImage?)
    func inputMedia(fileURL: URL, fileName: String, fileSize: Int64, fileId: String, imageThumbnail: UIImage?, isVideo: Bool)
    func removeFile(fileId: String)
    func imagePickerControllerDidDismiss()
    func onError(error: Error)
}
