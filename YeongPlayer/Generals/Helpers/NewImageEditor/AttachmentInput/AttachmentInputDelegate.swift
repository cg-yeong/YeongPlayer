

import UIKit

public protocol AttachmentInputDelegate: AnyObject {
    func inputImage(fileURL: URL, image: UIImage, fileName: String, fileSize: Int64, fileId: String, imageThumbnail: UIImage?)
    func inputMedia(fileURL: URL, imageThumbnail: UIImage?, fileName: String, fileSize: Int64, fileId: String, isVideo: Bool)
    func removeFile(fileId: String)
    func imagePickerControllerDidDismiss()
    func onError(error: Error)
}
