//
//  GiftList.swift
//  YeongPlayer
//
//  Created by inforex on 2021/11/01.
//

import UIKit

class GiftList: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userSexIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var sentTime: UILabel!
    @IBOutlet weak var rcvJewelCnt: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func configCell() {
        
    }
}
