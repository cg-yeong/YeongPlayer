//
//  ReceiveGiftList.swift
//  YeongPlayer
//
//  Created by inforex on 2021/11/01.
//

import UIKit
import RxSwift
import RxCocoa

class ReceiveGiftList: XibView {
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var total_money_label: UILabel!
    @IBOutlet weak var listTableView: UITableView!
    
    let bag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isInitialized {
            initialize()
            isInitialized = false
        }
    }
    
    func initialize() {
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.separatorStyle = .none
        listTableView.register(UINib(nibName: "GiftList", bundle: nil), forCellReuseIdentifier: "giftList")
        
        bind()
    }
    
    func bind() {
        
        
        
        closeBtn.rx.tap
            .bind {
                App.module.presenter.subView = nil
                self.removeFromSuperview()
            }.disposed(by: bag)
    }
}

extension ReceiveGiftList: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "giftList", for: indexPath) as? GiftList {
            cell.bounds.size.width = UIScreen.main.bounds.width
            cell.configCell()
            return cell
        } else {
            
            return UITableViewCell()
        }
    }
}
