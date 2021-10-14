//
//  PhotoAlbumCell.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/12.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class PhotoAlbumCell: UICollectionViewCell {
    
    @IBOutlet private var thumbnailView: UIImageView!
    @IBOutlet private var gradationView: UIView!
    @IBOutlet private var indicatorView: UIActivityIndicatorView!
    @IBOutlet private var movieIconView: UIImageView!
    @IBOutlet private var movieTimeLabel: UILabel!
    @IBOutlet private var checkIconView: UIImageView!
    @IBOutlet private var disableView: UIView!
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var selectView: UIView!
    
    private var bag = DisposeBag()
    
    override func awakeFromNib() {
        //labelShadow()
    }
    
    func setup(photo: AttachmentInputPhoto, status: AttachmentInputPhotoStatus, selectIndex: AttachmentInputPhotoSelectIndex) {
        self.bag = DisposeBag()
        self.movieIconView.isHidden = !photo.isVideo
        self.movieTimeLabel.isHidden = !photo.isVideo
        self.gradationView.isHidden = !photo.isVideo
        
        photo.initializeIfNeed(loadThumbnail: true)
        photo.properties
            .map { !$0.exceededSizeLimit } // 용량 제한 미만
            .asDriver(onErrorJustReturn: false)
            .drive(self.disableView.rx.isHidden)
            .disposed(by: self.bag)
        
        photo.videoTime
            .map { $0 }
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(self.movieTimeLabel.rx.text)
            .disposed(by: self.bag)
        
        photo.thumbnail
            .map { $0 }
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(self.thumbnailView.rx.image)
            .disposed(by: self.bag)
        
        selectIndex.output
            .map { String($0) }
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(self.countLabel.rx.text)
            .disposed(by: self.bag)
        
        status.ouput
            .distinctUntilChanged()
            .map { inputStatus in
                switch inputStatus {
                case .loading:
                    DispatchQueue.main.async {
                        self.countLabel.isHidden = false
                        self.indicatorView.isHidden = false
                        self.selectView.isHidden = false
                        self.layer.borderWidth = 2
                        self.layer.borderColor = UIColor(r: 255, g: 68, b: 114, a: 1).cgColor
                    }
                    return 0
                case .selected:
                    DispatchQueue.main.async {
                        self.countLabel.isHidden = false
                        self.selectView.isHidden = false
                        self.layer.borderWidth = 2
                        self.layer.borderColor = UIColor(r: 255, g: 68, b: 114, a: 1).cgColor
                    }
                    return 1
                case .unSelected:
                    DispatchQueue.main.async {
                        self.selectView.isHidden = true
                        self.countLabel.isHidden = true
                        self.layer.borderWidth = 2
                        self.layer.borderColor = UIColor(r: 255, g: 68, b: 114, a: 0).cgColor
                    }
                    return 0
                case .compressing, .downloading:
                    return 0
                }
            }.bind(to: self.checkIconView.rx.alpha)
            .disposed(by: self.bag)
        
        status.ouput
            .distinctUntilChanged()
            .map { inputStatus in
                switch inputStatus {
                case .compressing, .downloading:
                    return false
                default:
                    return true
                }
            }.bind(to: self.indicatorView.rx.isHidden)
            .disposed(by: self.bag)
    }
    
    private func setGradation(view: UIView) {
        let startColor = UIColor(white: 0, alpha: 0).cgColor
        let endColor = UIColor(white: 0, alpha: 0.8).cgColor
        
        let layer = CAGradientLayer()
        layer.colors = [startColor, endColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0.6)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
    }
    
    func labelShadow() {
        movieTimeLabel.layer.shadowColor = UIColor.black.cgColor
        movieTimeLabel.layer.shadowRadius = 3.0
        movieTimeLabel.layer.shadowOpacity = 1.0
        movieTimeLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
        movieTimeLabel.layer.masksToBounds = false
    }
    
    override func prepareForReuse() {
        self.thumbnailView.image = nil
    }
}
