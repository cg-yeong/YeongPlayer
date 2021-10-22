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
    @IBOutlet weak var photoStackView: UIStackView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

}

 

