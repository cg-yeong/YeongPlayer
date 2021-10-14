//
//  ImageCell.swift
//  Example
//
//  Created by daiki-matsumoto on 2018/08/17.
//  Copyright © 2018 Cybozu. All rights reserved.
//
import UIKit

protocol ImageCellDelegate: AnyObject {
    func tapedRemove(fileId: String, isVideo: Bool)
}

class ImageCell: UICollectionViewCell {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet weak var movieIconImageView: UIImageView!
    
    private var fileId: String = ""
    private var isVideo: Bool = false
    private weak var delegate: ImageCellDelegate?
    
    override func awakeFromNib() {
        self.imageView.layer.cornerRadius = 20
    }
    
    @IBAction func tapedRemove(_ sender: Any) {
        self.delegate?.tapedRemove(fileId: self.fileId, isVideo: self.isVideo)
    }
    
    func setup(data: PhotoData, delegate: ImageCellDelegate?) {
        movieIconImageView.isHidden = !data.isVideo
        self.imageView.image = data.image
        self.isVideo = data.isVideo
        self.fileId = data.fileId
        self.delegate = delegate
    }
    
}
