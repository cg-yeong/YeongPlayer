//
//  ABBorder.swift
//  YeongPlayer
//
//  Created by Oscar J. Irun on 27/11/16.
//  Copyright © 2016 appsboulevard. All rights reserved.

import UIKit

class ABBorder: UIView {
    
    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let image = UIImage(named: "BorderLine2")
        
        imageView.frame = self.bounds
        imageView.image = image
        imageView.contentMode = .scaleToFill
        self.addSubview(imageView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
    }
    
}
