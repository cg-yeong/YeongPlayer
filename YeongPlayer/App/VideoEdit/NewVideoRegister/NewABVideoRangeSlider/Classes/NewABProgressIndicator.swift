//
//  ABProgressIndicator.swift
//  Pods
//
//  Created by Oscar J. Irun on 2/12/16.
//
//

import UIKit

class NewABProgressIndicator: UIView {
    
    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let image = UIImage(named: "barPlayTime")
        imageView.frame = CGRect(origin: self.bounds.origin, size: CGSize(width: 21, height: self.bounds.height + 20))
        imageView.image = image
        self.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
