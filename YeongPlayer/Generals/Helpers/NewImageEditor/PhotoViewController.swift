//
//  MainViewController.swift
//  Example
//
//  Created by daiki-matsumoto on 2018/08/08.
//  Copyright © 2018 Cybozu. All rights reserved.
//
import UIKit
import RxSwift
import RxDataSources
import SwiftyJSON

class PhotoViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var photo_view: UIView!
    @IBOutlet weak var next_btn: UIButton!
    @IBOutlet weak var albums_btn: UIButton!
    @IBOutlet weak var photoStackView: UIStackView!
    
    @IBOutlet weak var albums_imageView: UIImageView!
    @IBOutlet weak var title_view: UIView!
    
    private let dbag = DisposeBag()
    private var attachmentInput: AttachmentInput!
    public var viewModel = PhotoViewModel()
//    private var dataSource: RxCollectionViewSectionedAnimatedDataSource<PhotoViewController>!
    
    internal var albumsManager = PLAlbumManager()
    
//    var galleryType: GalleryType?
    var jsonData: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.setupAttachmentInput()
    }

    override func viewDidAppear(_ animated: Bool) {
        if !self.isFirstResponder {
            self.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if self.isFirstResponder {
            self.resignFirstResponder()
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func setupCollectionView() {
        
        
        
        albums_btn.rx.tap
            .asDriver()
            .drive(onNext: { (_) in
                self.albums_btn.isSelected = !self.albums_btn.isSelected
                
                if self.albums_btn.isSelected {
                    self.albums_imageView.image = UIImage(named: "bulletUp")
                    App.module.presenter.addSubview(.visibleView, type: PhotoAlbumView.self) { view in
                        App.module.presenter.contextView = view
                        view.hView = self.title_view
                        view.albumsManager = self.albumsManager
                        view.didSelectAlbum = { [weak self] album in
                            self!.albums_imageView.image = UIImage(named: "bulletDown")
                            self?.setAlbum(album)
                            self?.albums_btn.setTitle(album.title, for: .normal)
                            self?.albums_btn.isSelected = false
                            //self?.attachmentInput.collectionView.setContentOffset(CGPoint.zero, animated: false)
                        }
                    }
                } else {
                    if let view = App.module.presenter.contextView as? PhotoAlbumView {
                        App.module.presenter.contextView = nil
                        view.removeFromSuperview()
                        self.albums_imageView.image = UIImage(named: "bulletDown")
                    }
                }
            }).disposed(by: dbag)
        
        back_btn.rx.tap
            .asDriver()
            .drive(onNext: { (_) in
                // 앨범 선택창이 열려있을 때 뒤로가기 : 앨범선택창 닫기
                // 닫혀있을 때 PhotoMain 닫기
                if let view = App.module.presenter.contextView as? PhotoAlbumView {
                    App.module.presenter.contextView = nil
                    view.removeFromSuperview()
                    self.albums_btn.isSelected = false
                    self.albums_imageView.image = UIImage(named: "bulletDown")
                } else {
                    self.attachmentInput = nil
                    self.dismiss(animated: true, completion: nil)
                }
            }).disposed(by: dbag)
        
        next_btn.rx.tap
            .asDriver()
            .drive(onNext: { (_) in
                // 1개 비디오만 있으면 비디오 편집으로 이동
                if self.viewModel.dataListValue.count == 1 && self.viewModel.dataListValue.first?.isVideo == true {
                    
                } else {
                    let videoFound = self.viewModel.dataListValue.filter({ $0.isVideo == true })
                    // 영상만 필터링한 결과
                    
                    if videoFound.isEmpty { // 모두 사진
                        
                    } else { // 비디오 사진 섞여있으면 그냥 업로드
//                        self.uploadMulti()
                    }
                }
            }).disposed(by: dbag)
        
    }
    
    func cropOpen(_ completion: (([UIImage]) -> Void)!) {
        var images = [UIImage]()
        for i in 0..<viewModel.dataListValue.count {
            images.append(viewModel.dataListValue[i].image!)
        }
        if let completion = completion {
            completion(images)
        }
    }
    
    private func setupAttachmentInput() {
        
    }
    
    func setAlbum(_ album: PLAlbum) {
        self.albums_btn.titleLabel!.text = album.title
        self.attachmentInput.changeImage(asset: album.collection!)
    }
    
}

 

