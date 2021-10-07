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

class PhotoViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var photo_view: UIView!
    @IBOutlet weak var send_btn: UIButton!
    @IBOutlet weak var albums_btn: UIButton!
    @IBOutlet weak var albums_imageView: UIImageView!
    @IBOutlet weak var title_view: UIView!
    
    private let disposeBag = DisposeBag()
    private var viewModel = PhotoViewModel()
    private var dataSource: RxCollectionViewSectionedAnimatedDataSource<PhotoViewController.SectionOfPhotoData>!
    
    internal var albumsManager = PLAlbumManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupCollectionView()
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

    private func setupCollectionView() {
        self.collectionView?.delegate = nil
        self.collectionView?.dataSource = nil
        self.collectionView.isHidden = true
        
        self.dataSource = RxCollectionViewSectionedAnimatedDataSource<PhotoViewController.SectionOfPhotoData>(configureCell: {
            (_: CollectionViewSectionedDataSource<PhotoViewController.SectionOfPhotoData>, collectionView: UICollectionView, indexPath: IndexPath, item: PhotoData) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            cell.setup(data: item, delegate: self)
            return cell
        }, configureSupplementaryView: { _,_,_,_ in
            fatalError()
        })

        self.viewModel.dataList.map { data in
            var ret = [SectionOfPhotoData]()
            ret.append(SectionOfPhotoData.Photos(items: data))
            if data.count <= 0 {
                UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                    self.collectionView.isHidden = true
                    self.collectionView.layoutIfNeeded()
                }, completion: nil)
                self.send_btn.setTitle("보내기", for: .normal)
                self.send_btn.setTitleColor(UIColor(r: 188, g: 188, b: 188), for: .normal)
                self.send_btn.isEnabled = false
            } else {
                if data.count == 1 {
                    UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                        self.collectionView.isHidden = false
                        self.collectionView.layoutIfNeeded()
                    }, completion: nil)
                    self.send_btn.setTitle("보내기 \(data.count)", for: .normal)
                    self.send_btn.setTitleColor(UIColor(r: 255, g: 68, b: 114), for: .normal)
                    self.send_btn.isEnabled = true
                } else if data.count > 5 {
                    self.send_btn.setTitle("보내기 \(data.count)", for: .normal)
                    self.send_btn.layoutIfNeeded()
                }
            }
            return ret
            }.bind(to: self.collectionView!.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        albums_btn.rx.tap
            .asDriver()
            .drive(onNext: { _ in
                
            }).disposed(by: disposeBag)
        
        back_btn.rx.tap
            .bind {
                
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
        
        send_btn.rx.tap
            .bind {
                
            }.disposed(by: disposeBag)
    }

    

    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    

    enum SectionOfPhotoData {
        case Photos(items: [PhotoData])
    }
    
    func setAlbum(_ album: PLAlbum) {
        self.albums_btn.titleLabel!.text = album.title
    }
    
    func scrollMove() {
        if self.viewModel.dataListValue.count >= 4 {
            let point = self.collectionView.contentSize.width - self.collectionView.frame.size.width + 65
            self.collectionView.setContentOffset(CGPoint(x: point, y: self.collectionView.contentOffset.y), animated: true)
        }
    }
    
    func uploadMulti(_ completion: ( () -> Void )? = nil ) {
        
    }
}

extension PhotoViewController: ImageCellDelegate {
    func tapedRemove(fileId: String, isVideo: Bool) {
        self.viewModel.removeData(fileId: fileId)
    }
}

extension PhotoData: IdentifiableType {
    typealias Identity = String
    var identity: String {
        return self.fileId
    }
}

extension PhotoViewController.SectionOfPhotoData: AnimatableSectionModelType {
    typealias Item = PhotoData
    typealias Identity = String
    
    var identity: String {
        return "PhotoSection"
    }
    
    var items: [PhotoData] {
        switch self {
        case .Photos(items: let items):
            return items
        }
    }
    
    init(original: PhotoViewController.SectionOfPhotoData, items: [PhotoData]) {
        self = .Photos(items: items)
    }
}



