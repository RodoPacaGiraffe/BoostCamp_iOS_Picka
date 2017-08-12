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
    
    @IBOutlet var detailImageView: UIImageView!
    var selectedSectionAsset: Int = 0
    var photoStore: PhotoStore?
    var selectedPhotos: [PHAsset]?
    var selectedIndex: Int = 0
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let asset = selectedPhotos?[selectedSectionAsset]
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
}

extension RemoveDetailPhotoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let storeAssets = selectedPhotos?.count else {
            print("There are no asset array")
            
            // MARK: return 0?
            return 0
        }
        print(storeAssets)
        return storeAssets
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "removeDetailPhotoCell", for: indexPath) as? RemoveDetailPhotoCell ?? RemoveDetailPhotoCell()
        guard let photoAsset = selectedPhotos?[indexPath.row] else { return UICollectionViewCell() }
        
        photoAsset.fetchImage(size: CGSize(width: 50.0, height: 50.0), contentMode: .aspectFill, options: nil, resultHandler: { (requestedImage) in
            cell.thumbnailImageView.image = requestedImage
        })
        
        return cell
    }
}

extension RemoveDetailPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         guard let photoAssets = selectedPhotos?[indexPath.row] else { return }
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        photoAssets.fetchFullSizeImage(options: options, resultHandler: { (data) in
            guard let data = data else { return }
            self.detailImageView.image = UIImage(data: data)
        })
        self.selectedIndex = indexPath.row
    }
}



