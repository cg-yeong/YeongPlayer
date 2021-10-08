//
//  ImageCell.swift
//  Example
//
//  Created by daiki-matsumoto on 2018/08/17.
//  Copyright © 2018 Cybozu. All rights reserved.
//
import UIKit

protocol ImageCellDelegate: AnyObject { // class
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
    
    @IBAction func tapRemove() {
        self.delegate?.tapedRemove(fileId: self.fileId, isVideo: self.isVideo)
    }
    
    func setup(data: PhotoData, delegate: ImageCellDelegate?) {
        self.imageView.image = data.image
//        self.fileName.text = data.fileName
//        self.fileSize.text = data.fileSize
        self.fileId = data.fileId
        self.delegate = delegate
    }
}
