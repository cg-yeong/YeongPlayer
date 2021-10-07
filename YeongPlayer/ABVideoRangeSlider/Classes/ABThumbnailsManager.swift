//
//  ABThumbnailsManager.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/14.
//

import UIKit
import AVFoundation

class ABThumbnailsManager: NSObject {
    
    var thumbnailViews = [UIImageView]()
    var thumbnailScale: CGFloat = 2 // 썸네일 한장 크기에 사진 몇개가 올라갈껀지 ?????
    
    private func addImagesToView(images: [UIImage], view: UIView) {
        
        self.thumbnailViews.removeAll()
        var posX: CGFloat = 0.0
        var width: CGFloat = 0.0
        for image in images {
            DispatchQueue.main.async {
                // UI작업
                if posX + view.frame.size.height < view.frame.width {
                    width = view.frame.size.height
                } else {
                    width = view.frame.size.width - posX
                } // ??? 무슨 길이 작업하는 거지
                
                let imageView = UIImageView(image: image)
                imageView.alpha = 0
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.frame = CGRect(x: posX, y: 0, width: width, height: view.frame.size.height)
                self.thumbnailViews.append(imageView)
                
                view.addSubview(imageView)
                UIView.animate(withDuration: 0.2) {
                    imageView.alpha = 1.0
                }
                view.sendSubviewToBack(imageView)
                // 이미지들 뷰를 슬라이더 뒤로?
                posX += (view.frame.size.height / self.thumbnailScale)
            }
        }
    }
    
    private func thumbnailCount(inView: UIView) -> Int {
        // 슬라이더 뒤에 있는 이미지뷰에 섬네일이 몇개 있는지 ?
        let num = Double(inView.frame.size.width) / Double(inView.frame.size.height) * 2
        return Int(ceil(num)) // 소수점 올림
        // 이거 가로 를 왜 세로로 나누고 2ㄹ를 곱하는거야????
    }
    
    func updateThumbnails(view: UIView, videoURL: URL, duration: Float64) {
        
        for view in self.thumbnailViews {
            DispatchQueue.main.async {
                view.removeFromSuperview()
                // 싹다 삭제하고 다시 추가하려고 닫는다
            }
        }
        self.thumbnailViews.removeAll()
        
        let imagesCount = self.thumbnailCount(inView: view)
        var offset: Float64 = 0
        var posX: CGFloat = 0.0
        var width: CGFloat = 0.0
        
        DispatchQueue(label: "com.app.queue").async {
            for i in 0 ..< imagesCount {
                let thumbnail = ABVideoHelper.thumbnailFromVideo(videoURL: videoURL, time: CMTimeMake(value: Int64(offset), timescale: 1))
                offset = Float64(i) * (duration / Float64(imagesCount))
                
                DispatchQueue.main.async {
                    if posX + view.frame.size.height < view.frame.width {
                        width = view.frame.size.height
                    } else {
                        width = view.frame.size.width - posX
                    }
                    
                    let imageView = UIImageView(image: thumbnail)
                    imageView.alpha = 0
                    imageView.contentMode = .scaleAspectFill
                    imageView.clipsToBounds = true
                    imageView.frame = CGRect(x: posX, y: 0, width: width, height: view.frame.size.height)
                    self.thumbnailViews.append(imageView)
                    
                    view.addSubview(imageView)
                    UIView.animate(withDuration: 0.2) {
                        imageView.alpha = 1
                    }
                    view.sendSubviewToBack(imageView)
                    posX += (view.frame.size.height / self.thumbnailScale)
                }
            }
        }
    }
    
}
