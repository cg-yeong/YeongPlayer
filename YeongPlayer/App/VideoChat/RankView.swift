//
//  LiveRankView.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/16.
//

import UIKit

class RankView: XibView {
    
    @IBOutlet var likeRankView: UIView!
    @IBOutlet weak var rankPopupView: UIView!
    @IBOutlet weak var rankTotalScoreLabel: UILabel!
    @IBOutlet weak var jewelScoreLabel: UILabel!
    @IBOutlet weak var timeScoreLabel: UILabel!
    @IBOutlet weak var likeScoreLabel: UILabel!
    @IBOutlet weak var jewelLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
