//
//  DetailViewController.swift
//  Electo
//
//  Created by byung-soo kwon on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos
class DetailPhotoViewController: UIViewController {
    
    @IBOutlet var detailImageView: UIImageView!
    @IBOutlet var thumbnailCollectionView: UICollectionView!
    
    var selectedSectionAsset: Int = .init()
    var photoStore: PhotoStore?
    var selectedPhotos: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView(thumbnailCollectionView, didSelectItemAt: IndexPath.init(row: 0, section: 0))
    }
    
    //Todo: Selecting removable photos
    @IBAction func selectForRemovePhoto(_ sender: UIButton) {
        print("selected!")
    }
    
    @IBAction func leftSwipeAction(_ sender: UISwipeGestureRecognizer) {
        guard let count = photoStore?.classifiedPhotoAssets[selectedSectionAsset].count else { return }
        //TODO: 개선
        selectedPhotos += 1
        if selectedPhotos == count {
            selectedPhotos -= 1
            return
        }
        let index = IndexPath(row: selectedPhotos, section: 0)
        collectionView(thumbnailCollectionView, didSelectItemAt: index)
        thumbnailCollectionView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    @IBAction func rightSwipeAction(_ sender: UISwipeGestureRecognizer) {
        selectedPhotos -= 1
        if selectedPhotos < 0 {
            selectedPhotos += 1
            return
        }
        let index = IndexPath(row: selectedPhotos, section: 0)
        collectionView(thumbnailCollectionView, didSelectItemAt: index)
        thumbnailCollectionView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
        
    }
}

extension DetailPhotoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let storeAssets = photoStore?.classifiedPhotoAssets[selectedSectionAsset] else {
            assertionFailure("There are no asset array")
            
            // MARK: return 0?
            return 0
        }
        return storeAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailPhotoCell", for: indexPath) as? DetailPhotoCell ?? DetailPhotoCell()
        let photoAsset = photoStore?.classifiedPhotoAssets[selectedSectionAsset][indexPath.item]
        
        photoAsset?.fetchImage(size: CGSize(width: 50.0, height: 50.0), contentMode: .aspectFill, options: nil,
                               resultHandler: { (requestedImage) in
                                cell.thumbnailImageView.image = requestedImage
        })
        
        return cell
    }
}

extension DetailPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoAssets = photoStore?.classifiedPhotoAssets[selectedSectionAsset][indexPath.item]
        selectedPhotos = indexPath.item
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        options.progressHandler = { [weak self] _ -> Void in
            guard let thumbnailViewCell = self?.thumbnailCollectionView.cellForItem(at: indexPath) as? DetailPhotoCell else {
                return
            }
            DispatchQueue.main.sync {
                self?.detailImageView.image = thumbnailViewCell.thumbnailImageView.image
            }
            
        }
        options.deliveryMode = .opportunistic
        
        DispatchQueue.global().async {
            photoAssets?.fetchFullSizeImage(options: options, resultHandler: { [weak self] (fetchedData) in
                guard let data = fetchedData else { return }
                DispatchQueue.main.async {
                    
                    self?.detailImageView.image = UIImage(data: data)
                }
            })
        }
    }
}
