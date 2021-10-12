//
//  ImagePickerCell.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/12.
//

import Foundation
import UIKit
import RxSwift
import AVFoundation
import MobileCoreServices
import SwiftyJSON

protocol ImagePickerCellDelegate: AnyObject {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    
    var videoQuality: UIImagePickerController.QualityType { get }
    
    func isSelectExceed() -> Bool
    func isVideoSelectExceed() -> Bool
}


class ImagePickerCell: UICollectionViewCell, CameraPermission {
    @IBOutlet weak var cameraButtonView: UIView!
    @IBOutlet weak var cameraButtonIcon: UIImageView!
    @IBOutlet weak var cameraButtonLabel: UILabel!
    
    private var imagePickerAuthorization = ImagePickerAuthorization()
    private var initialized = false
    private let bag = DisposeBag()
    weak var delegate: ImagePickerCellDelegate?
    
    var galleryType: Gallerytype?
    var jsonData = JSON()
    
    @IBAction func tapCamera(_ sender: Any) {
        guard let delegate = delegate else {
            return
        }
        
        if delegate.isSelectExceed() {
            return
        }
        
        // 사진이랑 동영상 팝업 호출
        if galleryType == .all {
            App.module.presenter.addSubview(.visibleView, type: GalleryPopupView.self) { view in
                view.openType = { type in
                    switch type {
                    case.photo:
                        self.openPhoto()
                    case.video:
                        self.openVideo()
                    case.none, .all:
                        return
                    }
                    
                }
                
            }
        } else if galleryType == .video {
            openVideo()
        } else {
            openPhoto()
        }
        
    }
    
    func openPhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = []
        if let videoQuality = self.delegate?.videoQuality {
            picker.videoQuality = videoQuality
        }
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        var topViewController = { () -> UIViewController? in
            if var top = UIApplication.shared.keyWindow?.rootViewController {
                while let presented = top.presentedViewController {
                    top = presented
                }
                return top
            }
            return nil
        }
        topViewController()?.present(picker, animated: true)
    }
    func openVideo() {
        Toast.show("동영상 촬영뷰 카메라 미구현", on: .visibleView)
    }
    
    func setup() {
        initializeIfNeed()
    }
    
    override func awakeFromNib() {
        setupText()
        setupDesign()
    }
    
    private func initializeIfNeed() {
        guard !self.initialized else {
            return
        }
        
        self.initialized = true
        self.imagePickerAuthorization.checkAuthorizaitonStatus()
        self.imagePickerAuthorization.videoDisable.subscribe(onNext: { [weak self] disable in
            DispatchQueue.main.async {
                self?.setupDesignForCameraButton(disable: disable)
            }
        }).disposed(by: bag)
        
    }
    
    func setupText() {
        self.cameraButtonLabel.text = String(format: NSLocalizedString("카메라 촬영", comment: ""))
    }
    func setupDesign() {
        setupDesignForCameraButton(disable: true)
    }
    private func setupDesignForCameraButton(disable: Bool) {
        if disable {
            self.cameraButtonIcon.alpha = 0.5
            self.cameraButtonLabel.alpha = 0.5
        } else {
            self.cameraButtonLabel.alpha = 1
            self.cameraButtonIcon.alpha = 1
        }
    }
}

extension ImagePickerCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            if picker.sourceType == UIImagePickerController.SourceType.camera {
                // 카메라로 찌근거면 사진저장
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            }
        }
        self.delegate?.imagePickerController(picker, didFinishPickingMediaWithInfo: info)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.delegate?.imagePickerControllerDidCancel(picker)
    }
}
