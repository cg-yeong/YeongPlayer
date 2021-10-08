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
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectCountView.layer.cornerRadius = selectCountView.frame.width / 2
        selectCountView.layer.borderColor = UIColor.white.cgColor
        selectCountView.layer.borderWidth = 2
        
        
        let selectTap = UITapGestureRecognizer(target: self, action: #selector(didSelect(_:)))
        selectView.addGestureRecognizer(selectTap)
        selectTap.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.thumbnail.bounds = CGRect(origin: .zero, size: CGSize(width: 150, height: 300))
        self.thumbnail.center = self.center
    }
    
    @objc func didSelect(_ recognizere: UITapGestureRecognizer) {
        if recognizere.state == UIGestureRecognizer.State.ended {
            selectDelegate?.selected(index: idx)
        }
    }
    
    func configCell(data: UIImage?) {
        if data != nil {
            self.thumbnail.image = data!
        }
    }
}
