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
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: RecordCell, bundle: nil), forCellWithReuseIdentifier: RecordCell)
        
        let chatFlowlayout = UICollectionViewFlowLayout()
        chatFlowlayout.minimumLineSpacing = 5.0
        chatFlowlayout.estimatedItemSize = CGSize(width: collectionView.frame.width, height: 50)
        collectionView.collectionViewLayout = chatFlowlayout
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        /// ------ 사진 --------------------------
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
//
        photoCollectionView.register(UINib(nibName: AlbumCell, bundle: nil), forCellWithReuseIdentifier: AlbumCell)
        let photoFlowLayout = UICollectionViewFlowLayout()
        photoFlowLayout.scrollDirection = .horizontal
        photoFlowLayout.minimumLineSpacing = 2.0
        photoFlowLayout.estimatedItemSize = CGSize(width: 150, height: photoCollectionView.frame.height)
        photoCollectionView.collectionViewLayout = photoFlowLayout
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionView {
            return recordingMsgList.count
        }
        if collectionView == photoCollectionView {
            return fetchResults.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionView {
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordCell, for: indexPath) as? RecordCell {
                
                cell.cellDelegate = self
                
                return cell
            }
            
        }
        if collectionView == photoCollectionView {
            collectionView.allowsMultipleSelection = true
            let items = photoCollectionView.indexPathsForSelectedItems
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCell, for: indexPath) as? AlbumCell else { return UICollectionViewCell() }
            let asset = self.fetchResults.object(at: indexPath.item)
            
            let imageOptions = PHImageRequestOptions()
            imageOptions.isSynchronous = true
            imageOptions.resizeMode = .fast
            imageOptions.isNetworkAccessAllowed = true
            imageOptions.deliveryMode = .highQualityFormat
            
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 150, height: photoCollectionView.frame.height), contentMode: .aspectFill, options: imageOptions) { (image, _) in
                cell.thumbnail.image = image
                
            }
            if let items = items, items.count > 0 {
                cell.selectCount.isHidden = false
                cell.selectCount.text = "\(items.count)"
            }
            
            cell.selectDelegate = self
            return cell
        } else {
            return UICollectionViewCell()
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == collectionView {
            let width = collectionView.contentSize.width
            return CGSize(width: width, height: 50)
        }
        if collectionView == photoCollectionView {
            return CGSize(width: 150, height: photoCollectionView.frame.height)
        } else {
            return CGSize(width: 150, height: 200)
        }
        
    }
    
    // 셀 선택 단발성이 아니야 껏다켰다 할 수 있어야 함
    
}

extension VoiceRecordView: CellPlayDelegate {
    func cellPlay(_ index: Int) {
        do {
            let action = try AVAudioPlayer(contentsOf: recordingMsgList[index].filePath)
            action.numberOfLoops = 0
            action.prepareToPlay()
            action.volume = 1
            action.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

extension VoiceRecordView: selectedDelegate {
    func selected(index: Int) {
        
    }
    
}
