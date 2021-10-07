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
    
    func fetchAlbums() -> [PLAlbum] {
        // 캐시된 앨범이 있으면 return으로 중복 방지 해주기
        if let cachedAlbums = cachedAlbums {
            return cachedAlbums
        }
        
        var albums = [PLAlbum]()
        let options = PHFetchOptions()
        options.accessibilityLanguage = ""
        let smartAlbumResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                       subtype: .any,
                                                                       options: options)
        let albumResult = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                  subtype: .any,
                                                                  options: options)
        // (0, album: title, count)
        for result in [smartAlbumResult, albumResult] {
            result.enumerateObjects { assetCollection, _, _ in
                var album = PLAlbum()
                album.title = assetCollection.localizedTitle ?? ""
                album.numberOfItems = self.mediaCountFor(collection: assetCollection)
                if album.numberOfItems > 0 {
                    let r = PHAsset.fetchKeyAssets(in: assetCollection, options: nil)
                    if let first = r?.firstObject {
                        let targetSize = CGSize(width: 78*2, height: 78*2)
                        let options = PHImageRequestOptions()
                        options.isSynchronous = true
                        options.deliveryMode = .highQualityFormat
                        PHImageManager.default().requestImage(for: first, targetSize: targetSize, contentMode: .aspectFit, options: options) { image, _ in
                            album.thumbnail = image
                        }
                    }
                    album.collection = assetCollection
                    
                    if !(assetCollection.assetCollectionSubtype == .smartAlbumSlomoVideos || assetCollection.assetCollectionSubtype == .smartAlbumVideos) {
                        albums.append(album)
                    }
                }
            }
        }
        cachedAlbums = albums
        return albums
    }
    
    func mediaCountFor(collection: PHAssetCollection) -> Int {
        let options = PHFetchOptions()
        let result = PHAsset.fetchAssets(in: collection, options: options)
        return result.count
    }
    
}
