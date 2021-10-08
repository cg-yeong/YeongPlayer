//
//  PLAlbumManager.swift
//  YeongPlayer
//
//  Created by inforex on 2021/10/07.
//

import Foundation
import Photos

class PLAlbumManager {
    
    private var cachedAlbums: [PLAlbum]?
    
    func fetchAlbums() ->  [PLAlbum] {
        
        // 캐싱된 앨범이 있으면 중복실행 방지
        if let cachedAlbums = cachedAlbums {
            return cachedAlbums
        }
        
        // 앨범 리스트: 앨범 배열
        var albums = [PLAlbum]()
        
        let options = PHFetchOptions()
        options.accessibilityLanguage = ""
        // 스마트앨범 메타데이터 가져오기 : 클라우드에 저장된, 외부 저장소에 저장된, 내 사진, Favorites, LivePhoto 중 아무거나 any
        let smartAlbumsResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                        subtype: .any,
                                                                        options: options)
        // 앨범 에셋 메타데이터 가져오기
        let albumsResult = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                   subtype: .any,
                                                                   options: options)
        // 스마트 앨범과 앨범을 묶어서 enumerate로 구분짓기
        // 그리고 썸네일 이미지 뽑기
        for result in [smartAlbumsResult, albumsResult] {
            result.enumerateObjects({ assetCollection, _, _ in
                
                // 앨범 데이터 담아줄 앨범 틀 만들기
                var album = PLAlbum()
                album.title = assetCollection.localizedTitle ?? ""
                album.numberOfItems = self.mediaCountFor(collection: assetCollection)
                
                if album.numberOfItems > 0 {
                    // 앨범 속 사진이 하나라도 있을 때
                    // ?
                    let r = PHAsset.fetchKeyAssets(in: assetCollection, options: nil)
                    // 첫번째 오브젝트로 썸네일 이미지하기
                    if let first = r?.firstObject {
                        let targetSize = CGSize(width: 78*2, height: 78*2)
                        let options = PHImageRequestOptions()
                        options.isSynchronous = true
                        options.deliveryMode = .highQualityFormat
                        
                        PHImageManager.default().requestImage(for: first,
                                             targetSize: targetSize,
                                             contentMode: .aspectFit,
                                             options: options,
                                             resultHandler: { image, _ in
                            album.thumbnail = image
                        })
                    }
                    album.collection = assetCollection
                    
                    // asset 서브타입이 스마트앨범- 느린비디오 or 비디오가 아닐때 앨범리스트에 앨범을 추가
                    if !(assetCollection.assetCollectionSubtype == .smartAlbumSlomoVideos
                        || assetCollection.assetCollectionSubtype == .smartAlbumVideos) {
                        albums.append(album)
                    }
                }
            })
        }
        // 앨범을 중복방지에 넣어주기
        cachedAlbums = albums
        return albums
    }
    
    // 미디어 개수 세기
    func mediaCountFor(collection: PHAssetCollection) -> Int {
        let options = PHFetchOptions()
        
        // 특정 collection: 앨범 안에서 사진들 가져오기
        let result = PHAsset.fetchAssets(in: collection, options: options)
        return result.count
    }
    
}
