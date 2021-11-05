//
//  ManageJavascriptBridge.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/28.
//

import UIKit
import MobileCoreServices
import Alamofire
import SwiftyJSON
import WebKit

@objc protocol WKWebViewControllerDelegate {
    @objc optional func webViewDidFinishLoad(_ webView: WKWebView)
    @objc optional func webViewDidStartLoad(_ webView: WKWebView)
    @objc optional func webView(_ webView: WKWebView, didFailLoadWithError error: Error)
    @objc func getStartPage() -> URLRequest
    @objc optional func setMainViewToolBarItemStatus()
}

class ManageJavascriptBridge: NSObject, UIScrollViewDelegate {
    
    var webView: WKWebView!
    var bridgeRouters: [String: (JSON, WVJBResponseCallback?) -> Void] = [:]
    var delegate: WKWebViewControllerDelegate?
    // bridgeRouters 헨들러안에서 작업이 끝나고 다른 delegate 함수에서 추가 작업이 있을경우 넘어온 데이타를 여기에 저장해놨다가 사용한다.
    var tempJsonData: JSON?
    var bridgeData: JSON?
    // 해당 브릿지를 포함하는 뷰컨트롤러가 로딩될때 웹뷰가 처음 로딩하고 나서 뭔가를 하라는 헨들러 데이타를 여기에 보관한다.
    var tempHandler: JSON?
    // 푸시가 와서 웹뷰한테 전달해야할 것이 있을때 웹뷰가 로딩중이면 여기에 보관한다.
    var pushStr: String?
    var isNotiOpen = false
    
    // 콜백 저장
    var responseCallback: WVJBResponseCallback?
    
    override init() {
        super.init()
//        self.initBridgeRouters()
    }
    
    func createWebView() -> WKWebView {
        let webConfig = WKWebViewConfiguration()
        webConfig.processPool = WKProcessPool()
        webConfig.websiteDataStore = WKWebsiteDataStore.default()
        webConfig.allowsInlineMediaPlayback = true
        
        // []: 빈 값 동영상 자동재생
        webConfig.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: webConfig)
        let startPage = delegate?.getStartPage()
        
        // user agent put information
        
        webView.load(startPage!)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.bounces = false
        webView.allowsLinkPreview = false
        
        self.registerHandlers(webView, sender: self)
        
        return webView
    }
    
    
    // 웹에서 보내는 데이터를 처리하기 위해 메인 핸들러 등록하기
    func registerHandlers(_ webView: WKWebView, sender: WKUIDelegate) {
        self.webView = webView
    }
    
}

extension ManageJavascriptBridge: UINavigationControllerDelegate {
    
}

extension ManageJavascriptBridge: WKNavigationDelegate {
    
}

extension ManageJavascriptBridge: WKUIDelegate {
    
}
