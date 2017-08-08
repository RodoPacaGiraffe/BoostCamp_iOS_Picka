//
//  DetailViewController.swift
//  Electo
//
//  Created by byung-soo kwon on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

class DetailPhotoViewController: UIViewController {
    
    @IBOutlet var detailImageView: UIImageView!
    var selectedSectionAsset: Int = 0
    var photoStore: PhotoStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let asset = photoStore?.classifiedPhotoAssets[selectedSectionAsset].first
        asset?.fetchImage(size: CGSize(width: 50, height: 50),
                          contentMode: .aspectFill,
                          options: nil) { photoImage in
                            self.detailImageView.image = photoImage
        }
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
        
        photoAssets?.forEach {
            $0.fetchImage(size: CGSize(width: 50, height: 50),
                          contentMode: .aspectFill, options: nil) { photoImage in
                            guard let photoImage = photoImage else { return }
                            cell.thumbnailImageView.image = photoImage
            }
        }
        return cell
    }
}

extension DetailPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoAssets = photoStore?.classifiedPhotoAssets[selectedSectionAsset][indexPath.item]
        photoAssets?.fetchImage(size: CGSize(width: 50, height: 50),
                                contentMode: .aspectFill, options: nil) { photoImage in
                                    guard let photoImage = photoImage else { return }
                                    self.detailImageView.image = photoImage
        }
    }
}
