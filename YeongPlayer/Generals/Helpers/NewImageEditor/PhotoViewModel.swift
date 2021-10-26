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
    } // dataListSubject 의 값이 있으면 내놓고 없으면 []() 빈데이터 반환
    
    let dataList: Observable<[PhotoData]>
    
    init() {
        self.dataList = dataListSubject.asObservable()
    }
    
    // addData(... = PhotoData)
    func addData(fileURL: URL?, fileName: String, fileSize: Int64, fileId: String, imageThumbnail: UIImage?, isVideo: Bool = false) {
        // ByteCountFormatter: 바이트 수 값을 적절한 바이트 수정자(KB, MB, GB 등)로 형식이 지정된 지역화된 설명으로 변환하는 포맷터입니다.
        let fileSizeString = ByteCountFormatter.string(fromByteCount: fileSize, countStyle: ByteCountFormatter.CountStyle.binary)
        let data = PhotoData(fileURL: fileURL, image: imageThumbnail, fileName: fileName, fileSize: fileSizeString, fileId: fileId, isVideo: isVideo)
        var newList = dataListValue
        
        newList.insert(data, at: newList.count)
        dataListSubject.onNext(newList)
        
    }
    
    func removeData(fileId: String) {
        let newList = dataListValue.filter({ $0.fileId != fileId })
        // 선택한 fileId와 다른것만 나오게 하기 -> 제거하기
        dataListSubject.onNext(newList)
        // 걸러진 리스트를 다시 스트림에 전달
    }
    
}
