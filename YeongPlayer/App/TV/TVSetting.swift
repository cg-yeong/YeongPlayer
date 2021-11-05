//
//  TVSetting.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/29.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class TVSetting: XibView {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var detailView: UIView!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var titleField: NoPasteTextField!
    @IBOutlet weak var placeholderView: UIStackView!
    
    @IBOutlet weak var liveModeView: UIView!
    @IBOutlet weak var generalLive: UIButton!
    @IBOutlet weak var secretLive: UIButton!
    
    @IBOutlet var liveButtons: [UIButton]!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var settingViewHeightConst: NSLayoutConstraint!
    
    
    
    
    @IBOutlet weak var liveStartBtn: UIButton!
    
    private var lastSelectedIndexPath: IndexPath?
    
    var isSecretSelected = BehaviorRelay<Bool>(value: false)
    
    
    let bag = DisposeBag()
    let letters = ["일상", "개인", "음악", "스포츠", "기타", "저스트채팅", "asdfawefwfa", "일상", "개인", "음악", "스포츠", "기타", "저스트채팅", "asdfawefwfa", "일상aa", "개인dddd", "ss음악", "스포츠", "기ddddff타", "저스트채팅"]
//    let letters = ["일상", "개인", "음악", "스포츠", "기타", "저스트채팅"]
    
    
    
    var isFirstCreated: Bool = true
    
    
    /// 뷰들을 추가하거나 제거, 뷰들의 크기나 위치를 업데이트, 레이아웃 constraint 를 업데이트, 뷰와 관련된 기타 프로퍼티들을 업데이트
    override func layoutSubviews() { // 뷰 수정이 있을때마다
        super.layoutSubviews()
        if isInitialized {
            allInit()
            reload()
            isInitialized = false
        }
        log.d("뷰 나오?")
        
        
    }
    
    
    
    deinit {
        log.d("설정화면 없어진다")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    
    
    
    
    func allInit() {
        titleField.delegate = self
        passwordField.delegate = self
        setView()
        bind()
    }
    
    func setView() {
        buttonColor()
        if !isFirstCreated {
            
        }
    }
    
    func bind() {
        setCollection()
        
//        let other_tap = UITapGestureRecognizer()
//        detailView.addGestureRecognizer(other_tap)
//
//        other_tap.rx.event
//            .bind { _ in
//                self.endEditing(true)
//            }.disposed(by: bag)
        
        
      /* let titleFieldValid = titleField.rx.text.orEmpty
            .map { !$0.isEmpty }
            .share(replay: 1)
        titleFieldValid.bind(to: placeholderView.rx.isHidden)
            .disposed(by: bag) */
        titleField.rx.text.orEmpty
            .map { !$0.isEmpty }
            .bind(to: placeholderView.rx.isHidden)
            .disposed(by: bag)
        
        closeBtn.rx.tap
            .bind { _ in
                if !self.titleField.text!.isEmpty {
                    // Alert
                } else {
                    self.removeFromSuperview()
                }
            }.disposed(by: bag)
        
        generalLive.rx.tap
            .bind {
                self.generalLive.isSelected = !self.generalLive.isSelected
                print(self.generalLive.isSelected)
            }.disposed(by: bag)
        
        
        
        secretLive.rx.tap
            .bind {
                
            }.disposed(by: bag)
        
        
        
        liveStartBtn.rx.tap
            .bind {
                self.validTitle()
            }.disposed(by: bag)
       
        
    }
    
    
    func reload() {
        let height = tagCollectionView.collectionViewLayout.collectionViewContentSize.height
        settingViewHeightConst.constant = height + tagCollectionView.frame.minX + liveModeView.frame.height
        self.layoutIfNeeded()
    }
    
    
    // MARK: 방송제목 문자열 검사
    func validTitle() {
        let titleFieldText = titleField.text!//.trimmingCharacters(in: .whitespaces)
        let postData = [
            "cmd" : "isContainFtvBadWord",
            "str" : "\(titleFieldText)"
        ]
        print("원래단어 : ", titleField.text!)
        print("검열단어 : ", titleFieldText)
        
        
        // 클럽5678에서 GlobalData.apiPage // Utils - requestAPI(params, completion)이용하자
        let checkURL = "http://devm-hoya.club5678.com/_global/api/index.php"
        
        AF.request(checkURL, method: .post, parameters: postData, encoding: URLEncoding.default, headers: nil)
            .responseJSON { response in
                
                switch response.result {
                    
                case .success(let data):
                    let result = JSON(data)
                    print(result)
                    if result["retvalue"].boolValue == true { // 금지어 있음
                        Toast.show("제목에 금지단어가 포함되어 있습니다.", on: .visibleView)
                    } else if result["retvalue"].boolValue == false { // 금지어 없음
                        Toast.show("\(titleFieldText)", on: .visibleView)
                    }
                case .failure:
                    
                    print("문자열 검사 체크 오류")
                }
            }
    }
    
    
    func setCollection() {
        tagCollectionView.collectionViewLayout = CollectionViewLeftAlignFlowLayout()
        if let flow = tagCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }

        
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
        
        tagCollectionView.register(UINib(nibName: "LiveTag", bundle: nil), forCellWithReuseIdentifier: "liveTag")
        tagCollectionView.allowsMultipleSelection = false
        
        
    }
    
    func buttonColor() {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.cornerRadius = CGFloat(liveStartBtn.frame.height / 2)
        gradient.frame = liveStartBtn.bounds
        gradient.colors = [
            UIColor(r: 255, g: 121, b: 116).cgColor,
            UIColor(r: 255, g: 55, b: 142).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.locations = [0.2, 1]
        liveStartBtn.layer.addSublayer(gradient)
    }
    
}



extension TVSetting: UICollectionViewDelegate, UICollectionViewDataSource {
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let item = letters[indexPath.row]
//        let itemSize = CGSize(width: item.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]).width + 25, height: 30)
//
//        return itemSize
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return letters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "liveTag", for: indexPath) as? LiveTag {
            cell.configCell() // cornerRadius
            cell.idx = indexPath.item
            cell.tagName.text = letters[indexPath.item]
           
            if indexPath.row == 0 {
                lastSelectedIndexPath = indexPath
                cell.isSelected = true
                collectionView.selectItem(at: lastSelectedIndexPath, animated: false, scrollPosition: .init())
            }
            
            cell.isSelected = (lastSelectedIndexPath == indexPath)
            // 모든 셀의 isSelected를 false로 만들어주기
            
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("셀 선택선택 \(indexPath)")
        guard lastSelectedIndexPath != indexPath else { return }
        
        if let index = lastSelectedIndexPath {
            let cell = collectionView.cellForItem(at: index) as! LiveTag
            cell.isSelected = false
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! LiveTag
        cell.isSelected = true
        print("\(letters[indexPath.row]) == \(cell.tagName.text!)")
        lastSelectedIndexPath = indexPath
    }
   
    
    
    
}

// MARK: 정규식 이용해서 이모티콘 제외한 문자만 입력가능하게 하기
extension TVSetting: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        /*
        if textField == titleField {
            let utf8Char = string.cString(using: .utf8)
            let isBackSpace = strcmp(utf8Char, "\\b")
            if string.hasRegexCharacters() || isBackSpace == -92 {

                guard let textFieldText = textField.text,
                      let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                          return false
                      }

                var tCount: Int = 0
                if string.isEmpty {
                    tCount = textField.text!.count - 1
                } else {
                    tCount = textField.text!.count + string.count
                }

                let subStringToReplace = textFieldText[rangeOfTextToReplace]
                let count = textFieldText.count - subStringToReplace.count + string.count
                return count <= 20
            }
        }

        return false */
    
        if let char = string.cString(using: .utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        
        if textField == titleField {
            guard textField.text!.count <= 20 else { return false }
        } else if textField == passwordField {
            guard textField.text!.count <= 4 else { return false }
        }
        
        
        return true
    }
}
