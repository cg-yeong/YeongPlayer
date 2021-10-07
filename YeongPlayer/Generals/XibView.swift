//
//  XibView.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/15.
//

import Foundation
import UIKit
import SwiftyJSON

class XibView: UIView {
    var viewData: JSON = JSON()
    var isInitialized = true
    var appearViewListenr: (() -> Void)? = nil
    var removeViewListenr: (() -> Void)? = nil
    
    required init(frame: CGRect, viewData: JSON) {
        super.init(frame: frame)
        self.viewData = viewData
        self.tag = 555
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        self.tag = 555
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
        self.tag = 555
    }
    private func commonInit() {
        guard let xibName = NSStringFromClass(self.classForCoder).components(separatedBy: ".").last else { return }
        if let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(view)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if let listener = appearViewListenr, isInitialized {
            listener()
        }
    }
    override func removeFromSuperview() {
        super.removeFromSuperview()
        if let listener = removeViewListenr {
            listener()
        }
    }
    
    func terminate(_ completion: (() -> Void)? = nil) {  }
    
}
