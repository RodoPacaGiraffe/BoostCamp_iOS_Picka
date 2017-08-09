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
    var selectedSectionAsset: Int = 0
    var photoStore: PhotoStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let asset = photoStore?.classifiedPhotoAssets[selectedSectionAsset].first
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

extension DetailPhotoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let storeAssets = photoStore?.classifiedPhotoAssets[selectedSectionAsset] else {
            print("There are no asset array")
            
            // MARK: return 0?
            return 0
        }
        return storeAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailPhotoCell", for: indexPath) as? DetailPhotoCell ?? DetailPhotoCell()
        let photoAssets = photoStore?.classifiedPhotoAssets[selectedSectionAsset]
        photoAssets?.forEach{
            $0.fetchImage(size: CGSize(width: 50.0, height: 50.0), contentMode: .aspectFill, options: nil, resultHandler: { (image) in
                cell.thumbnailImageView.image = image
            })
        }
        return cell
    }
}

extension DetailPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoAssets = photoStore?.classifiedPhotoAssets[selectedSectionAsset][indexPath.item]
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        photoAssets?.fetchFullSizeImage(options: options, resultHandler: { (data) in
            guard let data = data else { return }
            self.detailImageView.image = UIImage(data: data)
        })
    }
}
