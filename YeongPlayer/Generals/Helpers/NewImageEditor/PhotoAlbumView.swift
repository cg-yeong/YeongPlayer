//
//  PhotoAlbumView.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/07.
//

import UIKit
import SwiftyJSON
import RxCocoa
import RxSwift

class PhotoAlbumView: XibView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var another_view: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_heightConstant: NSLayoutConstraint!
    
    // 앨범 선택완료 했을 때 실행할 구문
    var didSelectAlbum: ((PLAlbum) -> Void)?
    
    // 앨범 리스트: 앨범들 배열
    var albums: [PLAlbum] = []
    var albumsmanager: PLAlbumManager!
    var bag = DisposeBag()
    
    // 앨범 리스트 선택 페이지 전의 앨범 전체보기에서 겹치는 뒤로가기버튼, 앨범버튼, 보내기 버튼 뷰
    var hView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isInitialized {
            initialize()
            isInitialized = false
        }
    }
    
    override func removeFromSuperview() {
        App.module.presenter.contextView = nil
        super.removeFromSuperview()
    }
    
    func initialize() {
        setView()
        bind()
    }
    
    func setView() {
        // 상태바 프레임 구하기
        let statusBarHeight = Utility.getStatusBarHeight()
        // 상태바 바로 아래부터 앨범리스트 테이블 뷰 구현하기
        self.frame = CGRect(x: 0,
                            y: hView.frame.height + statusBarHeight,
                            width: UIScreen.main.bounds.width,
                            height: UIScreen.main.bounds.height - hView.frame.height)
        
        setUpTableView()
        fetchAlbumsInBackground()
        
    }
    
    func bind() {
        let without = UITapGestureRecognizer()
        another_view.addGestureRecognizer(without)
        
        // throttle: 이벤트 발생 후 1초동안 이벤트 막기 latest = false: 중복방지? true: 좋아요?
        without.rx.event
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind { _ in
                self.removeFromSuperview()
            }.disposed(by: bag)
    }
    
    func setUpTableView() {
        tableView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "PLAlbumCell", bundle: nil), forCellReuseIdentifier: "PLAlbumCell")
    }
    
    func fetchAlbumsInBackground() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // 앨범매니저의 fetchAlbums() 를 앨범 리스트로
            self?.albums = self?.albumsmanager.fetchAlbums() ?? []
            DispatchQueue.main.async {
                self?.tableView.isHidden = false
                self?.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let album = albums[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PLAlbumCell", for: indexPath) as? PLAlbumCell {
            
            cell.thumbnail.backgroundColor = .gray
            cell.thumbnail.image = album.thumbnail
            cell.titleLabel.text = album.title
            cell.numberOfItems.text = "\(album.numberOfItems)장"
            
            return cell
        }
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectAlbum?(albums[indexPath.row])
        self.removeFromSuperview()
    }
    
    
}
