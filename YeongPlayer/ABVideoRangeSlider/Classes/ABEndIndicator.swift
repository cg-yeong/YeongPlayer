//
//  ABEndIndicator.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/14.
//

import UIKit

class ABEndIndicator: UIView {
    var imageView = UIImageView()
    // end inicator 조작 가능하게 
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        
        let image = UIImage(named: "EndIndicator2")
        
        imageView.frame = self.bounds
        imageView.image = image
        imageView.contentMode = .scaleToFill
        self.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
