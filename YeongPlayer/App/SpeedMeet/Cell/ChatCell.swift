//
//  ChatCell.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/28.
//

import UIKit

class ChatCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var chatText: UILabel!
    @IBOutlet weak var sendTime: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        initialize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func initialize() {
        
    }
    
}
