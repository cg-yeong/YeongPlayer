//
//  ABThumbnailsHelper.swift
//  selfband
//
//  Created by Oscar J. Irun on 27/11/16.
//  Copyright © 2016 appsboulevard. All rights reserved.
//

import UIKit
import AVFoundation

class NewABThumbnailsManager: NSObject {
    
    var thumbnailViews = [UIImageView]()
    var thunmailScale: CGFloat = 2              // 썸네일 한장크기에 사진 몇개가 올라갈꺼냐? (겹치게될경우...)

    private func addImagesToView(images: [UIImage], view: UIView){
        
        self.thumbnailViews.removeAll()
        var xPos: CGFloat = 0.0
        var width: CGFloat = 0.0
        for image in images{
            DispatchQueue.main.async {
                if xPos + view.frame.size.height < view.frame.width{
                    width = view.frame.size.height
                }else{
                    width = view.frame.size.width - xPos
                }
                
                let imageView = UIImageView(image: image)
                imageView.alpha = 0
                imageView.contentMode = UIView.ContentMode.scaleAspectFill
                imageView.clipsToBounds = true
                imageView.frame = CGRect(x: xPos,
                                         y: 0.0,
                                         width: width,
                                         height: view.frame.size.height)
                self.thumbnailViews.append(imageView)
                
                
                view.addSubview(imageView)
                UIView.animate(withDuration: 0.2, animations: {
                    imageView.alpha = 1.0
                })
                
                view.sendSubviewToBack(imageView)
                xPos = xPos + view.frame.size.height / self.thunmailScale
            }
        }
    }
    
    private func thumbnailCount(inView: UIView) -> Int{
        //let num = Double(inView.frame.size.width) / Double(inView.frame.size.height) * 2
        return 5
    }
    
    func updateThumbnails(view: UIView, videoURL: URL, duration: Float64, startTime : Float = 0) {
        
        for view in self.thumbnailViews{
            DispatchQueue.main.async {
                view.removeFromSuperview()
            }
        }
        self.thumbnailViews.removeAll()
        
        let imagesCount = self.thumbnailCount(inView: view)
        var offset: Float64 = Float64(startTime)
        var thumbnailTime = startTime
        var width: CGFloat = 0.0
        
        DispatchQueue(label: "com.app.queue").async {
            for i in 0 ..< imagesCount {
                offset = Float64(i) * (duration / Float64(imagesCount))
                thumbnailTime = Float(Int64(offset) + Int64(startTime))
                //log.d(thumbnailTime)
                let thumbnail = NewABVideoHelper.thumbnailFromVideo(videoUrl: videoURL, time: CMTimeMake(value: Int64(thumbnailTime), timescale: 1))
                DispatchQueue.main.async {
                    width = view.frame.size.width/CGFloat(imagesCount)
                    let imageView = UIImageView(image: thumbnail)
                    imageView.alpha = 0
                    imageView.contentMode = UIView.ContentMode.scaleAspectFill
                    imageView.clipsToBounds = true
                    //log.d(width * CGFloat(i))
                    imageView.frame = CGRect(x: width * CGFloat(i),
                                             y: 0.0,
                                             width: width,
                                             height: view.frame.size.height)
                    self.thumbnailViews.append(imageView)
    
    
                    view.addSubview(imageView)
                    UIView.animate(withDuration: 0.2, animations: {
                        imageView.alpha = 1.0
                    })
    
                    view.sendSubviewToBack(imageView)
                }
            }
        }
    }
}
