//
//  ViewController.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/09.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit
import SwiftyJSON

class ViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var album: UIButton!
    @IBOutlet weak var camera: UIButton!
    @IBOutlet weak var videoChat: UIButton!
    @IBOutlet weak var record: UIButton!
    @IBOutlet weak var TV_Live: UIButton!
    
    var bag = DisposeBag()
    
    var viewController: String { return "vc" }
    var videoRecord: String { return "videoRecord" }
    var videoSelector: String { return "videoSelector" }
    var videoEditor: String { return "videoEditor" }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        bind()
        
        
        
    }
    func createWeb() {
        let web: WKWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        web.navigationDelegate = self
        self.view.addSubview(web)
        
        let myURL = URL(string: "https://www.naver.com")
        let req = URLRequest(url: myURL!)
        web.load(req)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.frame.size.height = 300
        webView.scrollView.contentSize = webView.frame.size
    }
    
    func bind() {
        TV_Live.rx.tap
            .bind { _ in
                App.module.presenter.addSubview(.visibleView, type: TV.self) { view in
                    App.module.presenter.contextView = view
                    view.viewData = JSON()
                }
            }.disposed(by: bag)
        
        album.rx.tap
            .bind { _ in
                print("앨범 ㅋ킄")
                guard let albumVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: self.videoSelector) as? VideoSelectVC else { return }
                albumVC.modalPresentationStyle = .overFullScreen
                self.present(albumVC, animated: true, completion: nil)
                
            }.disposed(by: bag)
        
        camera.rx.tap
            .bind { _ in
                print("캠 킄킄")
                guard let camVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: self.videoRecord) as? VideoRecordVC else { return }
                camVC.modalPresentationStyle = .overFullScreen
                self.present(camVC, animated: true, completion: nil)
                
            }.disposed(by: bag)
        
        videoChat.rx.tap
            .bind {
//                self.view.addSubview(VideoChatView.init(frame: self.view.bounds))
                App.module.presenter.addSubview(.visibleView, type: VideoChatView.self) { view in
                    App.module.presenter.contextView = view
                }
            }.disposed(by: bag)
        
        record.rx.tap
            .bind {
                App.module.presenter.addSubview(.visibleView, type: VoiceRecordView.self) { view in
                    App.module.presenter.contextView = view
                    view.viewData = ""
                }
            }.disposed(by: bag)
        
    }
    
    
    
    func setView() {
        
        
        
    }
}

