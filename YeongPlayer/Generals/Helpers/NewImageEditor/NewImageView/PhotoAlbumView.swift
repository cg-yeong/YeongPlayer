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

class PhotoAlbumView: XibView {
    
    
    @IBOutlet weak var another_view: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_heightConstant: NSLayoutConstraint!
    
    var didSelectAlbum: ((PLAlbum) -> Void)?
    var albums: [PLAlbum] = []
    var albumsManager: PLAlbumManager!
    var dbag = DisposeBag()
    
    var hView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isInitialized {
            initialize()
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
        
    }
    
    func setupTableView() {
        
    }
    
    func bind() {
        
    }
    
}
