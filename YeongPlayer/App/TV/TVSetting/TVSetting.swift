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
    @IBOutlet weak var generalLive: KindRadioButton!
    @IBOutlet weak var secretLive: KindRadioButton!
    
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var pwPlaceholderLabel: UILabel!
    @IBOutlet weak var pwSecureOnOff: UIButton!
    
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var settingViewHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var liveStartBtn: UIButton!
    
    @IBOutlet var kindRadioBtns: [KindRadioButton]!
    var shouldLetDeSelect = false // 라디오 버튼 선택한게 다시 눌러서 취소 될수 있는지
    
    private var lastSelectedIndexPath: IndexPath?
    
    
    
    let bag = DisposeBag()
    let letters = ["일상", "개인", "음악", "스포츠", "기타", "저스트채팅"]
//    let letters = ["일상", "개인", "음악", "스포츠", "기타", "저스트채팅"]
    
    
    
    var isFirstSetting: Bool = true
    
    
    /// 뷰들을 추가하거나 제거, 뷰들의 크기나 위치를 업데이트, 레이아웃 constraint 를 업데이트, 뷰와 관련된 기타 프로퍼티들을 업데이트
    override func layoutSubviews() { // 뷰 수정이 있을때마다
        super.layoutSubviews()
        if isInitialized {
            allInit()
            setView()
            
            
            reload()
            
            
            isInitialized = false
        }
        
        
        
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
        
        bind()
    }
    
    func setView() {
        buttonColor()
        
        if isFirstSetting { // 수정화면이니까 소켓 콜백으로 오는거 세팅하기
            generalLive.isSelected = true
            secretLive.isSelected = false
            
            passwordField.isHidden = true
            pwPlaceholderLabel.isHidden = true
            pwSecureOnOff.isHidden = true
            
            print(didSelectButton(selectedButton: nil)!.titleLabel!.text!)
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
        
        
        /*let titleFieldValid = titleField.rx.text.orEmpty
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
                    self.endEditing(true)
                    CHAlert.CustomAlert(on: .visibleView, "작성 사항을 취소 하시겠습니까?", leftAction: AlertAction(title: "취소"), rightAction: AlertAction(title: "확인", action:  self.removeFromSuperview) )
                } else {
                    self.removeFromSuperview()
                }
            }.disposed(by: bag)
        
        let pwFieldValid = passwordField.rx.text.orEmpty
            .map{ !$0.isEmpty }
            .distinctUntilChanged()
            
        pwFieldValid
            .bind(to: pwPlaceholderLabel.rx.isHidden)
            .disposed(by: bag)
        
        pwFieldValid
            .map { !$0 }
            .bind(to: pwSecureOnOff.rx.isHidden)
            .disposed(by: bag)
        
//        passwordField.rx.text.orEmpty
//            .map { !$0.isEmpty }
//            .bind(to: pwPlaceholderLabel.rx.isHidden)
//            .disposed(by: bag)
        
        pwSecureOnOff.rx.tap
            .bind { _ in
                self.passwordField.isSecureTextEntry = !self.passwordField.isSecureTextEntry
            }.disposed(by: bag)
        
        kindRadioBtns.forEach { kind in
            kind.rx.tap
                .bind { _ in
                    self.radioPressed(kind)
                    print(kind.titleLabel!.text!, kind.isSelected, self.kindRadioBtns.firstIndex(where: { $0.isSelected })!)
                    
                    
                    
                }.disposed(by: bag)
        }
        
        generalLive.rx.tap
            .bind {
                
            }.disposed(by: bag)
        
        secretLive.rx.tap
            .bind {
                
            }.disposed(by: bag)
        
        liveStartBtn.rx.tap
            .bind {
//                guard !self.titleField.text!.trimmingCharacters(in: .whitespaces).isEmpty else {
//                    Toast.show("제목을 입력해주세요")
//                    return
//                }
//
//                if self.didSelectButton(selectedButton: nil)!.titleLabel!.text == "비밀방" {
//                    guard !self.passwordField.text!.isEmpty else {
//                        Toast.show("비밀번호를 설정해주세요.")
//                        return
//                    }
//                }
                
                self.validTitle(completion: { retData in
                    let result = retData as! Bool
                    if result == true {
                        print(" 데이터 점검해야 할거같은데? , 점검분기 토스트")
                        
                    } else {
                        print(" 방송방 데이터 담아서 보내기 ")
                        let params: [String : String] = [
                            "cmd" : ""
                        ]
                        self.isFirstSetting = false
                        // callscript funcName
                    }
                
                    
                })
                
            }.disposed(by: bag)
       
        
    }
    
    
    func radioPressed(_ sender: UIButton) {
        var currentKindBtn: UIButton? = nil
        
        if sender.isSelected { // 선택한것 누르는 건데 false로 아무 실행 안하게 처리해주기
            if shouldLetDeSelect { // 선택했던것 다시 취소 : 지금은 실행 X
                sender.isSelected = false
                currentKindBtn = nil
            }
        } else { // 다른거 선택했을 때
            kindRadioBtns.forEach { kind in
                kind.isSelected = false
                kind.backgroundColor = .lightGray
                // 전체 취소
            }
            sender.isSelected = true // 누른 것만 선택되게
            sender.backgroundColor = .orange
            currentKindBtn = sender
            _ = didSelectButton(selectedButton: currentKindBtn)
            
            
            if sender == generalLive {
                print("비밀번호 없어져라~")
                self.passwordField.isHidden = true
                self.pwPlaceholderLabel.isHidden = true
                self.pwSecureOnOff.isHidden = true
            } else if sender == secretLive {
                print("비밀번호 창 나와라")
                self.passwordField.isHidden = false
                if (self.passwordField.text ?? "").isEmpty { // 비밀번호 입력한 것 검사
                    self.pwPlaceholderLabel.isHidden = false
                } else {
                    self.pwSecureOnOff.isHidden = false
                }
            }
            
        }
        
        
        
    }
    
    func didSelectButton(selectedButton: UIButton?) -> UIButton? {
        guard let index = kindRadioBtns.firstIndex(where: { button in button.isSelected }) else { return nil }
        
        return kindRadioBtns[index]
    }
    
    func reload() {
        let height = tagCollectionView.collectionViewLayout.collectionViewContentSize.height
        settingViewHeightConst.constant = height + tagCollectionView.frame.minX + liveModeView.frame.height
        self.layoutIfNeeded()
    }
    
    
    // MARK: 방송제목 문자열 검사
    func validTitle(completion: ((Any) -> Void)?) {
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
                        if let callback = completion {
                            callback(true)
                        }
                    } else if result["retvalue"].boolValue == false { // 금지어 없음
                        Toast.show("\(titleFieldText)", on: .visibleView)
                        if let callback = completion {
                            callback(false)
                        }
                    }
                case .failure:
                    if let callback = completion {
                        callback(["retmsg" : "9999"])
                    }
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
            // 초기에 셀 그릴때만 작동
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("셀 선택선택 \(indexPath)")
        guard lastSelectedIndexPath != indexPath else { return } // 다른것만 선택되게 걸러주기
        
        if let lastidx = lastSelectedIndexPath { // 마지막선택 인덱스
            let cell = collectionView.cellForItem(at: lastidx) as! LiveTag // 마지막 선택된 셀을 찾고, 선택 취소해주기
            cell.isSelected = false
            log.d("선택했던것 다시 선택해서 취소하기 \(lastidx.row)")
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! LiveTag // 내가 선택한 셀을 찾고, 선책하기
        cell.isSelected = true
        print("\(letters[indexPath.row]) == \(cell.tagName.text!)")
        log.d("선택 해주기 \(indexPath.row)")
        lastSelectedIndexPath = indexPath
    }
   
    
    
    
}

// MARK: 정규식 이용해서 이모티콘 제외한 문자만 입력가능하게 하기
extension TVSetting: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // textField.text!.count + string.count - range.length > 20
        
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
        
        if textField == titleField {
            guard textField.text!.count <= 20 else { return false }
        } else if textField == passwordField {
            guard textField.text!.count < 4 else {
                passwordField.resignFirstResponder()
                return false
            }
            return true
        }

        return false
    
//        if let char = string.cString(using: .utf8) {
//            let isBackSpace = strcmp(char, "\\b")
//            if isBackSpace == -92 {
//                return true
//            }
//        }
//
//        if textField == titleField {
//            guard textField.text!.count <= 20 else { return false }
//        } else if textField == passwordField {
//            guard textField.text!.count < 4 else {
//                passwordField.resignFirstResponder()
//                return false
//            }
//        }
//
//
//        return true
    }
}
