//
//  ABTimeView.swift
//  Pods
//
//  Created by Oscar J. Irun on 12/12/16.
//
//

import UIKit

class NewABTimeView: UIView {

    let space: CGFloat = 8.0
    
    var timeLabel       = UILabel()
    var backgroundView  = UIView() {
        willSet(newBackgroundView){
            self.backgroundView.removeFromSuperview()
        }
        didSet {
            self.frame = CGRect(x: 0,
                                y: -backgroundView.frame.height - space,
                                width: backgroundView.frame.width,
                                height: backgroundView.frame.height)
            
            self.addSubview(backgroundView)
            self.sendSubviewToBack(backgroundView)
        }
    }
    
    var marginTop: CGFloat       = 5.0
    var marginBottom: CGFloat    = 5.0
    var marginLeft: CGFloat      = 5.0
    var marginRight: CGFloat     = 5.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(size: CGSize, position: Int){
        let frame = CGRect(x: 0,
                           y: -size.height - space,
                           width: size.width,
                           height: size.height)
        super.init(frame: frame)
        
        // Add Background View
        self.backgroundView.frame = self.bounds
        self.backgroundView.backgroundColor = UIColor.yellow
        self.addSubview(self.backgroundView)
        
        // Add time label
        self.timeLabel = UILabel()
        self.timeLabel.textAlignment = .center
        self.timeLabel.textColor = UIColor.lightGray
        self.addSubview(self.timeLabel)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundView.frame = self.bounds
        self.timeLabel.frame = CGRect(x: marginLeft,
                                      y: marginTop - self.timeLabel.bounds.height / 2,
                                      width: self.frame.width - (marginRight + marginLeft),
                                      height: self.frame.height - (marginBottom + marginTop))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
