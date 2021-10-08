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
    @IBOutlet weak var photo_stackView: UIStackView!
    
    @IBOutlet weak var albums_imageView: UIImageView!
    @IBOutlet weak var title_view: UIView!
    
    private let bag = DisposeBag()
    
    internal var albumsManager = PLAlbumManager()
    
    var viewModel = PhotoViewModel()
    
    // 웹이랑 소통할 틀 만들어놓기만
    var jsonData = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
        self.collectionView.isHidden = true
        
        
        
        albums_btn.rx.tap
            .asDriver()
            .drive(onNext: { _ in
                // 상단 앨범 버튼 누를때 마다 앨범 리스트들이 펴졌다가 접혔다가 & 옆의 이미지도 v or ㅅ down up 이미지 변경
                self.albums_btn.isSelected = !self.albums_btn.isSelected
                // 앨범은 스마트 앨범, 앨범: PHAssetCollection -> PHAsset
                if self.albums_btn.isSelected {
                    self.albums_imageView.image = UIImage(named: "bulletUp")
                    // 앨범 페이지 펼쳐주기 -> 앨범 선택시 다시 이미지 bulletDown으로 바꿔주기 & 앨범리스트 접기
                    App.module.presenter.addSubview(.visibleView, type: PhotoAlbumView.self) { view in
                        App.module.presenter.contextView = view
                        
                        view.hView = self.title_view
                        // 앨범 매니저 관리 전달받기 그래서 선언을 !로 할 수 있었던 것
                        view.albumsmanager = self.albumsManager
                        
                        // 앨범 선택했을 때 실행할 구문 지금 정하고 전달하기
                        view.didSelectAlbum = { [weak self] album in
                            self!.albums_imageView.image = UIImage(named: "bulletDown")
                            // 앨범 세팅
                            self?.setAlbum(album)
                            // 앨범 리스트 버튼이니까 setTitle로 버튼 텍스트 바꾸기
                            self?.albums_btn.setTitle(album.title, for: .normal)
                            // 앨범 버튼 isSelected 조정
                            self?.albums_btn.isSelected = false
                            // 밑에 있는 attachmentInput의 원점으로 돌아가 앨범 새로 여는 효과 넣기
                        }
                    }
                } else {
                    // 앨범 페이지가 펼쳐져있을 때만 이미지 변경
                    if let view = App.module.presenter.contextView as? PhotoAlbumView {
                        App.module.presenter.contextView = nil
                        view.removeFromSuperview()
                        self.albums_imageView.image = UIImage(named: "bulletDown")
                    }
                }
                
            }).disposed(by: bag)
        
        back_btn.rx.tap
            .asDriver()
            .drive(onNext: { _ in
                // 앨범리스트 펼쳐져있을 땐 앨범리스트 닫기 & 접혀져있을 땐 선택창 내리기
                if let view = App.module.presenter.contextView as? PhotoAlbumView {
                    App.module.presenter.contextView = nil
                    view.removeFromSuperview()
                    self.albums_btn.isSelected = false
                    self.albums_imageView.image = UIImage(named: "bulletDown")
                } else {
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }).disposed(by: bag)
        
        next_btn.rx.tap
            .asDriver()
            .drive(onNext: { _ in
                
                Toast.show("선택 파일 종류 구분하고 업로드 구현하기", on: .visibleView)
                // 비디오 , 사진, 믹스 구분 하고 마지막에 업로드 메소드
                
            }).disposed(by: bag)
        
        
    }
    
    func setAlbum(_ album: PLAlbum) {
        // 앨범 선택했을 때 메인에 있는 것 변경
        self.albums_btn.titleLabel?.text = album.title
        // self.attachmentInput.changeImage(asset: album.collection!)
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

}

 

