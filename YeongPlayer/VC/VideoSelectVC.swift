//
//  VideoSelectVC.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/10.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class VideoSelectVC: UIViewController {
    
    @IBOutlet weak var closeSelect: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noDataImg: UIImageView!

    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        
    }
    
    func bind() {
        
        closeSelect.rx.tap
            .bind { _ in
                self.dismiss(animated: true, completion: nil)
            }.disposed(by: bag)
        
    }
    
}
