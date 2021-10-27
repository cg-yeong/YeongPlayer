//
//  ABStartIndicator.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/14.
//

import UIKit

class ABStartIndicator: UIView {
    // 인디케이터: 이미지 뷰인데 옮겨다니기 해야한다
    
    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        
        let image = UIImage(named: "StartIndicator2")
        
        imageView.frame = self.bounds
        imageView.image = image
        imageView.contentMode = .scaleToFill
        self.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
