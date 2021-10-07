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
    
    var albums: [PLAlbum] = []
    var albumsManager: PLAlbumManager!
    var disposeBag = DisposeBag()
    var didSelectAlbum: ( (PLAlbum) -> Void )?
    
    var hview: UIView!
    
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
        // let statusBarHeight = UIApplication.shared.statusBarFrame.height
        // _ = self.window?.windowScene?.statusBarManager?.statusBarFrame.height
        let statusBarHeight = Utility.getStatusBarHeight()
        self.frame = CGRect(x: 0,
                            y: hview.frame.height + statusBarHeight,
                            width: UIScreen.main.bounds.width,
                            height: UIScreen.main.bounds.height - hview.frame.height)
    }
    
    func bind() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
