//
//  MainViewModel.swift
//  Example
//
//  Created by daiki-matsumoto on 2018/08/17.
//  Copyright © 2018 Cybozu. All rights reserved.
//

import RxSwift

class PhotoViewModel {
    let dataListSubject = BehaviorSubject<[PhotoData]>(value: [])
    var dataListValue: [PhotoData] {
        let defaultValue = [PhotoData]()
        return (try? dataListSubject.value()) ?? defaultValue
    }
    
    let dataList: Observable<[PhotoData]>
    
    init() {
        self.dataList = dataListSubject.asObservable()
    }
    
    func addData(fileURL: URL?, fileName: String, fileSize: Int64, fileId: String, imageThumbnail: UIImage?, isVideo: Bool = false) {
        let fileSizeString = ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .binary)
        let data = PhotoData(fileURL: fileURL, image: imageThumbnail, fileName: fileName, fileSize: fileSizeString, fileId: fileId, isVideo: isVideo)
        var newList = dataListValue
        
        newList.insert(data, at: newList.count) // 0 ? append?
        dataListSubject.onNext(newList)
    }
    
    func removeData(fileId: String) {
        let newList = dataListValue.filter { $0.fileId != fileId } // 같은것 거르기
        dataListSubject.onNext(newList)
    }
                                
}
