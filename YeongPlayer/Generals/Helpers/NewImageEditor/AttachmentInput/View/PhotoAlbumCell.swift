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
        
        
    }
    
    
    
}
