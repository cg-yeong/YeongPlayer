//
//  ABProgressIndicator.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/14.
//

import UIKit

class ABProgressIndicator: UIView {
    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let image = UIImage(named: "ProgressIndicator2")
        
        imageView.frame = self.bounds
        imageView.image = image
        imageView.contentMode = .scaleToFill
        self.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let frame = CGRect(x: -self.frame.size.width / 2, y: 0,
                           width: self.frame.size.width * 2, height: self.frame.size.height)
        
        // 여유있는 seeking 인디케이터인가?
        if frame.contains(point) {
            return self
        } else { return nil }
    }
}
