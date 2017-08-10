//
//  RemoveDetailViewController.swift
//  Electo
//
//  Created by byung-soo kwon on 2017. 8. 9..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos
class RemoveDetailPhotoViewController: UIViewController {
    
    @IBOutlet var thumbnailCollectionView: UICollectionView!
    @IBOutlet var detailImageView: UIImageView!
    var selectedSectionAsset: Int = 0
    var photoStore: PhotoStore?
    var selectedPhotosAsset: [PHAsset]?
    var selectedPhotos: Int = 0
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let asset = selectedPhotosAsset?[selectedSectionAsset]
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        asset?.fetchFullSizeImage(options: options, resultHandler: { (data) in
            guard let data = data else { return }
            self.detailImageView.image = UIImage(data: data)
        })
    }
    
    //Todo: Selecting removabxwle photos
    @IBAction func selectForRemovePhoto(_ sender: UIButton) {
        print("selected!")
    }
    
    @IBAction func leftSwipeAction(_ sender: UISwipeGestureRecognizer) {
        guard let count = photoStore?.classifiedPhotoAssets[selectedSectionAsset].count else { return }
        //TODO: 개선할 것이 있을까?
        selectedPhotos += 1
        guard selectedPhotos == count else {
            selectedPhotos -= 1
            return
        }
        let index = IndexPath(row: selectedPhotos, section: 0)
        collectionView(thumbnailCollectionView, didSelectItemAt: index)
        thumbnailCollectionView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    @IBAction func rightSwipeAction(_ sender: UISwipeGestureRecognizer) {
        selectedPhotos -= 1
        guard selectedPhotos < 0 else {
            selectedPhotos += 1
            return
        }
        let index = IndexPath(row: selectedPhotos, section: 0)
        collectionView(thumbnailCollectionView, didSelectItemAt: index)
        thumbnailCollectionView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
        
    }

}

extension RemoveDetailPhotoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let storeAssets = selectedPhotosAsset?.count else {
            print("There are no asset array")
            
            // MARK: return 0?
            return 0
        }
        print(storeAssets)
        return storeAssets
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "removeDetailPhotoCell", for: indexPath) as? RemoveDetailPhotoCell ?? RemoveDetailPhotoCell()
        guard let photoAssets = selectedPhotosAsset?[indexPath.row] else { return UICollectionViewCell() }
        
        photoAssets.fetchImage(size: CGSize(width: 50.0, height: 50.0), contentMode: .aspectFill, options: nil, resultHandler: { (image) in
            cell.thumbnailImageView.image = image
        })
        
        return cell
    }
}

extension RemoveDetailPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         guard let photoAssets = selectedPhotosAsset?[indexPath.row] else { return }
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        photoAssets.fetchFullSizeImage(options: options, resultHandler: { [weak self] (data) in
            guard let data = data else { return }
            self?.detailImageView.image = UIImage(data: data)
        })
        self.selectedPhotos = indexPath.row
    }
}



