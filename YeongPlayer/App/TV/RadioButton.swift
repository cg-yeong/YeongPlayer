//
//  RadioButton.swift
//  YeongPlayer
//
//  Created by inforex on 2021/11/01.
//

import UIKit

class RadioButton: UIButton {
    var liveKinds: Array<RadioButton>?
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.backgroundColor = UIColor(r: 255, g: 149, b: 0, a: 1).cgColor
            } else {
                self.layer.backgroundColor = UIColor(r: 102, g: 102, b: 102, a: 1).cgColor
            }
        }
    }
    
    
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 17
        
    }
    
    func unSelectAlternateButtons() {
        if liveKinds != nil {
            self.isSelected = true
            
            for aButton: RadioButton in liveKinds! {
                aButton.isSelected = false
            }
        } else {
            toggleButton()
        }
    }
    
    func toggleButton() {
        self.isSelected = !isSelected
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        unSelectAlternateButtons()
        super.touchesBegan(touches, with: event)
    }
    
    
}
