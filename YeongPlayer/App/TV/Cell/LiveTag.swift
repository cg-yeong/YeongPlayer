//
//  TitleTag.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/29.
//

import UIKit
import RxSwift


class LiveTag: UICollectionViewCell {
    
    @IBOutlet weak var tagName: UILabel!
    
    var idx = 0
    var wasSelected: Bool = false
    let bag = DisposeBag()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = .orange
            } else {
                backgroundColor = .lightGray
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //bind()
        
    }
    
    func configCell() {
        self.layer.cornerRadius = 7
        

    }
    
    func bind() {
        let click = UITapGestureRecognizer()
        self.addGestureRecognizer(click)

        click.rx.event
            .bind { _ in
                print("rxcell click : \(self.idx), \(self.tagName.text!)")


//                self.isSelected = !self.isSelected

            }.disposed(by: bag)
    }
    
    
}
