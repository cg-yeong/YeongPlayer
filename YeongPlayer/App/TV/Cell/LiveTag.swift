//
//  TitleTag.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/29.
//

import UIKit
import RxSwift


class LiveTag: UICollectionViewCell {
    
    @IBOutlet weak var tagName: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = .orange
            } else {
                backgroundColor = .lightGray
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configCell() {
        self.layer.cornerRadius = 7
    }
    
    
}
