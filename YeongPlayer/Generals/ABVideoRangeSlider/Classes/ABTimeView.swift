//
//  ABTimeView.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/15.
//

import UIKit

class ABTimeView: UIView {
    
    let space: CGFloat = 0
    var timeLabel = UILabel()
    var backgroundView = UIView() {
        willSet(newBackgroundView) {
            self.backgroundView.removeFromSuperview()
        }
        didSet {
            self.frame = CGRect(x: 0, y: -backgroundView.frame.height - space,
                                width: backgroundView.frame.width, height: backgroundView.frame.height)
            self.addSubview(backgroundView)
            self.sendSubviewToBack(backgroundView)
        }
    }
    
    var marginTop: CGFloat = 5
    var marginBottom: CGFloat = 5
    var marginLeft: CGFloat = 5
    var marginRight: CGFloat = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(size: CGSize, position: Int) {
        let frame = CGRect(x: 0, y: -size.height - space,
                           width: size.width, height: size.height)
        super.init(frame: frame)
        
        self.backgroundView.frame = self.bounds
        self.backgroundView.backgroundColor = .yellow
        self.addSubview(self.backgroundView)
        
        self.timeLabel = UILabel()
        self.timeLabel.textAlignment = .center
        self.timeLabel.textColor = .lightGray
        self.addSubview(timeLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundView.frame = self.bounds
        self.timeLabel.frame = CGRect(x: marginLeft, y: marginTop,
                                      width: self.frame.width - (marginLeft + marginRight),
                                      height: self.frame.height - (marginTop + marginBottom))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
