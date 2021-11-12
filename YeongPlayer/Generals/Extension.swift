//
//  Extension.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/16.
//

import Photos
import UIKit
import RxSwift
import RxCocoa

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
}
extension String {
    var toTime : String {
        get {
            var retStr = ""
            
            let seconds = Int(self)
            
            guard (seconds != nil) else {
                return "0초"
            }
            
            if seconds == 0 {
                retStr = "0초"
            } else {
                let hour = seconds! / (60 * 60)
                let min = (seconds! - hour * 60) / 60
                let sec = (seconds! - hour * 60) % 60

                if hour > 0{
                    retStr += "\(hour)시간"
                }
                
                if min > 0 {
                    if retStr != "" {
                        retStr += " "
                    }
                    retStr += "\(min)분"
                }
                
                if sec > 0 {
                    if retStr != "" {
                        retStr += " "
                    }
                    retStr += "\(sec)초"
                }
            }
            
            return retStr
        }
    }
    
    var emojilessStringWithSubstitution: String {
        let textWithoutEmoji = self.unicodeScalars
            .filter { !$0.properties.isEmojiPresentation }
            .filter { !$0.properties.isBidiMirrored }
            .filter { $0 != "\u{2764}" }
            .reduce("") { $0 + String($1) }
        
        return textWithoutEmoji
    }
    
    func hasRegexCharacters() -> Bool {
        do { // $£•¥₩
            let regex = try NSRegularExpression(pattern: "^[0-9a-zA-Z가-힣ㄱ-ㅎㅏ-ㅣ`~!@#$£•¥₩%^&*()\\-_=+\\[{\\]}\\\\|;:'\",<.>/?\\s]$", options: .caseInsensitive)
            if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.count)) {
                return true
            }
        } catch {
            return false
        }
        return false
    }
    
    
    
}

extension Int {
    var toTime: String {
        get {
            var retStr = ""
            
            let seconds = self

            if seconds == 0 {
                retStr = "0초"
            } else {
                let hour = seconds / (60 * 60)
                let min = (seconds - hour * 60) / 60
                let sec = (seconds - hour * 60) % 60

                if hour > 0{
                    retStr += "\(hour)시간"
                }
                
                if min > 0 {
                    if retStr != "" {
                        retStr += " "
                    }
                    retStr += "\(min)분"
                }
                
                if sec > 0 {
                    if retStr != "" {
                        retStr += " "
                    }
                    retStr += "\(sec)초"
                }
            }
            
            return retStr
        }
    }
    var toColonTime: String {
        get {
            let (_, m, s) = (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
            let m_string = m < 10 ? "0\(m)" : "\(m)"
            let s_string = s < 10 ? "0\(s)" : "\(s)"
            
            return "\(m_string):\(s_string)"
        }
    }
}



extension UIView {
    
    func animateUp(_ duration: TimeInterval = 0.5, delay: Double = 0, completion: ((Bool)  -> Void)? = nil) {
        self.frame.origin.y = self.bounds.height
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseIn], animations: {
            self.frame.origin.y = 0
        }, completion: completion)
        self.isHidden = false
    }
    func animateDown(_ duration: TimeInterval = 0.5, delay: Double = 0, completion: ((Bool)  -> Void)? = nil) {
        
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseIn], animations: {
            self.center.y = self.bounds.height
        }, completion: completion)
        
        UIView.animate(withDuration: duration, delay: delay, options: [.curveLinear], animations: {
            self.frame.origin.y = self.bounds.height
        }, completion: completion)
    }
    
    func getMaxCornerRadius(view: UIView) -> CGFloat {
        let width = self.bounds.maxX - self.bounds.minX
        let height = self.bounds.maxY - self.bounds.minY
        
        let gijun = min(width, height)
        
        return gijun.truncatingRemainder(dividingBy: 2)
    }
    
}

extension TimeInterval {
    var hourMinuteSecondMS: String {
        String(format:"%d:%02d:%02d.%03d", hour, minute, second, millisecond)
    }
    var minuteSecond: String {
        String(format:"%d:%02d", minute, second)
    }
    var hour: Int {
        Int((self/3600).truncatingRemainder(dividingBy: 3600))
    }
    var minute: Int {
        Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        Int(truncatingRemainder(dividingBy: 60))
    }
    var millisecond: Int {
        Int((self*1000).truncatingRemainder(dividingBy: 1000))
    }
}

/// https://stackoverflow.com/questions/38183613/how-to-get-url-for-a-phasset
extension PHAsset {
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
        if self.mediaType == .image {
            let options = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = { (adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) in
                completionHandler(contentEditingInput?.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

extension UIApplication {
    public class func openURL(url: URL) {
        if #available(iOS 10.0, *) {
            shared.open(url, options: [:], completionHandler: nil)
        } else {
            shared.openURL(url)
        }
    }
}

extension Reactive where Base: UIButton {
    public var isSelectedChanged: ControlProperty<Bool> {
        return base.rx.controlProperty(editingEvents: [.allEditingEvents, .touchUpInside],
                                       getter: { $0.isSelected },
                                       setter: { $0.isSelected = $1 })
    }
    
    public var isBtnSelected: ControlProperty<Bool> {
        return base.rx.controlProperty(editingEvents: .touchUpInside,
                                       getter: ({ button in
                                                    button.isSelected
                                                }),
                                       setter: ({ button, selected in
                                                    if button.isSelected != selected {
                                                        button.isSelected = selected
                                                    }
                                                }))
    }
    
}


class NoPasteTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

class KindRadioButton: UIButton {
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.backgroundColor = .orange
            } else {
                self.backgroundColor = .lightGray
            }
        }
    }
    
    
}


