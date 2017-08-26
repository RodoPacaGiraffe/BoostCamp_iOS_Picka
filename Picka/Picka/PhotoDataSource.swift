//
//  PhotoDataSource.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 7..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

fileprivate struct Constants {
    struct CellIdentifier {
        static let classifiedPhotoCell: String = "ClassifiedPhotoCell"
        static let temporaryPhotoCell: String = "TemporaryPhotoCell"
    }
}

class PhotoDataSource: NSObject, NSKeyedUnarchiverDelegate {
    var photoStore: PhotoStore = PhotoStore()
    
    var temporaryPhotoStore: TemporaryPhotoStore = TemporaryPhotoStore() {
        didSet {
            temporaryPhotoStore.delegate = photoStore
        }
    }
    
    override init() {
        temporaryPhotoStore.delegate = photoStore
        
        super.init()
    }
}

extension PhotoDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return photoStore.classifiedGroupsByDate.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoStore.classifiedGroupsByDate[section].classifiedPHAssetGroups.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return photoStore.classifiedGroupsByDate[section].date.toDateString()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let classifiedPhotoCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.classifiedPhotoCell,
                                                                for: indexPath)
            as? ClassifiedPhotoCell ?? ClassifiedPhotoCell()
        
        let classifiedPHAssetGroup = photoStore.classifiedGroupsByDate[indexPath.section]
            .classifiedPHAssetGroups[indexPath.row]
        
        var fetchedImages: [UIImage] = []
        
        if !classifiedPhotoCell.requestIDs.isEmpty {
            classifiedPhotoCell.requestIDs.forEach {
                CachingImageManager.shared.cancelImageRequest($0)
            }
            
            classifiedPhotoCell.removeAllrequestIDs()
        }
        
        classifiedPHAssetGroup.photoAssets.forEach {
            let requestID = $0.fetchImage(size: SettingConstants.fetchImageSize, contentMode: .aspectFill, options: nil) { photoImage in
                guard let photoImage = photoImage else { return }
                fetchedImages.append(photoImage)
                                        
                if classifiedPHAssetGroup.photoAssets.count == fetchedImages.count {
                    classifiedPhotoCell.setCellImages(with: fetchedImages)
                    classifiedPhotoCell.removeAllrequestIDs()
                }
            }
            
            classifiedPhotoCell.appendRequestID(requestID: requestID)
        }
        
        let assetCounts: Int = classifiedPHAssetGroup.photoAssets.count
        var localizedString: String = ""
        
        if Locale.preferredLanguages.first == Language.arabic {
            localizedString = assetCounts.toArabic() + NSLocalizedString(LocalizationKey.numberOfPhotos, comment: "")
        } else {
            localizedString = NSLocalizedString(LocalizationKey.numberOfPhotos, comment: "")
        }
    
        classifiedPhotoCell.setNumberOfPhotosLableText(with: String(format: localizedString, assetCounts))

        return classifiedPhotoCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let classifiedGroupsByDate = photoStore.classifiedGroupsByDate[indexPath.section]
        let assets = classifiedGroupsByDate.classifiedPHAssetGroups[indexPath.row]
        
        temporaryPhotoStore.insert(photoAssets: assets.photoAssets)
        
        if classifiedGroupsByDate.classifiedPHAssetGroups.count == 1 {
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension PhotoDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return temporaryPhotoStore.photoAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let temporaryPhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifier.temporaryPhotoCell,
                                                                    for: indexPath)
            as? TemporaryPhotoCell ?? TemporaryPhotoCell()
        let temporaryPhotoAsset = temporaryPhotoStore.photoAssets[indexPath.item]

        if let selectedItems = collectionView.indexPathsForSelectedItems,
            selectedItems.contains(indexPath) {
            temporaryPhotoCell.select()
        } else {
            temporaryPhotoCell.deSelect()
        }
        
        temporaryPhotoAsset.fetchImage(size: SettingConstants.fetchImageSize, contentMode: .aspectFill, options: nil) { photoImage in
            temporaryPhotoCell.setThumbnailImage(thumbnailImage: photoImage)
        }
    
        return temporaryPhotoCell
    }
}

