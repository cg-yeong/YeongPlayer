//
//  AlbumCell.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/05.
//

import UIKit

protocol selectedDelegate {
    func selected(index: Int)
}

class AlbumCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var selectView: UIView!
    @IBOutlet weak var selectCountView: UIView!
    @IBOutlet weak var selectCount: UILabel!
    
    @IBOutlet weak var isVideoView: UIStackView!
    @IBOutlet weak var videoTime: UILabel!
    
    var selectDelegate: selectedDelegate?
    var idx: Int = 0
    var representedAssetIdentifier: String?
    var selectedIndex: AttachmentInputPhotoSelectIndex!
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.selectView.isHidden = false
                self.selectCountView.backgroundColor = UIColor(r: 255, g: 68, b: 114, a: 1)
                
                self.selectCount.isHidden = false
                self.selectCount.text = "\(idx)"
                
            } else {
                self.selectView.isHidden = true
                self.selectCountView.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.3)
                self.selectCount.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectCountView.layer.cornerRadius = selectCountView.frame.width / 2
        selectCountView.layer.borderColor = UIColor.white.cgColor
        selectCountView.layer.borderWidth = 2
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configCell(with image: UIImage?) {
        if image != nil {
            self.thumbnail.image = image!
        }
    }
}
