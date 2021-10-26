//
//  VoiceRecordView+Collection.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/28.
//

import UIKit
import Photos
import Lottie

extension VoiceRecordView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func setCollectionView() {
        chatCollectionView.dataSource = self
        chatCollectionView.delegate = self
        
        chatCollectionView.register(UINib(nibName: RecordCell, bundle: nil), forCellWithReuseIdentifier: RecordCell)
        chatCollectionView.register(UINib(nibName: ChatCell, bundle: nil), forCellWithReuseIdentifier: ChatCell)
        
        let chatFlowlayout = UICollectionViewFlowLayout()
        chatFlowlayout.minimumLineSpacing = 5.0
        chatFlowlayout.estimatedItemSize = CGSize(width: chatCollectionView.frame.width, height: 50)
        chatCollectionView.collectionViewLayout = chatFlowlayout
        chatCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == chatCollectionView {
            return chatData.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == chatCollectionView {
            switch chatData[indexPath.row].status {
            case ChatCell:
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCell, for: indexPath) as? ChatCell {
                    cell.chatText.text = chatData[indexPath.row].chat
                    cell.sendTime.text = "오후 6:00"
                    cell.userName.text = "파댕스"
                    return cell
                }
                
            case RecordCell:
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordCell, for: indexPath) as? RecordCell {
                    return cell
                }
            default:
                break
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.contentSize.width
        if collectionView == chatCollectionView {
            switch chatData[indexPath.row].status {
            case ChatCell: return CGSize(width: width, height: 100)
            case RecordCell: return CGSize(width: width, height: 50)
            default: return CGSize(width: width, height: 0)
            }
        } else {
            return CGSize(width: 100, height: 100)
        }
        
    }
    
    // 셀 선택 단발성이 아니야 껏다켰다 할 수 있어야 함
    
}

extension VoiceRecordView: selectedDelegate {
    func selected(index: Int) {
        print("\(index) 셀 클릭")
    }
    
}
