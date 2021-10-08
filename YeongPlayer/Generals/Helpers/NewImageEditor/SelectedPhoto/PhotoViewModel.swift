//
//  MainViewModel.swift
//  Example
//
//  Created by daiki-matsumoto on 2018/08/17.
//  Copyright © 2018 Cybozu. All rights reserved.
//

import RxSwift

class PhotoViewModel {
    
    // 사진 선택 했을때 stackView 안에 들어가는 사진 배열 관찰
    let dataListSubject = BehaviorSubject<[PhotoData]>(value: [])
    var dataListValue: [PhotoData] {
        let defaultValue = [PhotoData]()
        return (try? dataListSubject.value()) ?? defaultValue
    }
    
    let dataList: Observable<[PhotoData]>
    
    init() {
        self.dataList = dataListSubject.asObservable()
    }
    
    func addData(fileURL: URL?, imageThumbnail: UIImage?, fileName: String, fileSize: Int64, fileId: String, isVideo: Bool = false) {
        let fileSizeString = ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .binary)
        let data = PhotoData(fileURL: fileURL, image: imageThumbnail, fileName: fileName, fileSize: fileSizeString, fileId: fileId, isVideo: isVideo)
        var newList = dataListValue // = [PhotoData]()
        
        newList.insert(data, at: newList.count) // =? append(item)
        dataListSubject.onNext(newList)
    }
    
    func removeData(fileId: String) {
        // 전달된 파일아이디가 아닌것으로 필터링 하기 자동적으로 제거된 배열이 newList에 담김
        let newList = dataListValue.filter({ $0.fileId != fileId })
        dataListSubject.onNext(newList)
    }
    
}
