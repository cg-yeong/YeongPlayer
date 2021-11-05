//
//  webviewpt.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/28.
//

import UIKit
import WebKit
import MediaPlayer
import AVKit

class webviewpt: XibView {
    
    var webView: WKWebView!
    var webViewController: ManageJavascriptBridge = ManageJavascriptBridge()
    
    @IBOutlet weak var webviewcontainer: UIView!
    
    
}
