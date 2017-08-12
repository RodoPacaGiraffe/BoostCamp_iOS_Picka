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
    
    @IBOutlet var zoomingScrollView: UIScrollView!
    @IBOutlet var detailImageView: UIImageView!
    @IBOutlet var thumbnailCollectionView: UICollectionView!
    @IBOutlet var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet var doubleTapRecognizer: UITapGestureRecognizer!
    
    
    var thumbnailImages: [UIImage] = .init()
    var selectedSectionAssets: [PHAsset] = []
    var selectedSection: Int = 0
    var photoStore: PhotoStore?
    var selectedPhotos: Int = 0
    var pressedIndexPath: IndexPath?
    var identifier: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.zoomingScrollView.minimumZoomScale = 1.0
        self.zoomingScrollView.maximumZoomScale = 6.0
        
        self.tabBarController?.tabBar.isHidden = true
        detailImageView.image = thumbnailImages[0]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView(thumbnailCollectionView, didSelectItemAt: IndexPath.init(row: 0, section: 0))
        doubleTapRecognizer.numberOfTapsRequired = 2
    }
    
    func setAsset(_ identifier: String) -> [PHAsset] {
        switch identifier {
        case "fromTemporaryViewController":
            return selectedSectionAssets
        default:
            guard let assets = photoStore?.classifiedPhotoAssets[selectedSection] else { return ([]) }
            return assets
        }
    }
    
    func changeSwipe(direction: String) {
        
        switch direction {
        case "right":
            selectedPhotos -= 1
            if selectedPhotos < 0 {
                selectedPhotos += 1
                return
            }
        case "left":
            let count = setAsset(identifier).count
            selectedPhotos += 1
            if selectedPhotos == count {
                selectedPhotos -= 1
                return
            }
        default:
            return
        }
    }
    
    //Todo: Selecting removable photos
    @IBAction func selectForRemovePhoto(_ sender: UIButton) {
        print("selected!")
    }
    
    @IBAction func leftSwipeAction(_ sender: UISwipeGestureRecognizer) {
        changeSwipe(direction: "left")
        let index = IndexPath(row: selectedPhotos, section: 0)
        collectionView(thumbnailCollectionView, didSelectItemAt: index)
        thumbnailCollectionView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    @IBAction func rightSwipeAction(_ sender: UISwipeGestureRecognizer) {
        changeSwipe(direction: "right")
        let index = IndexPath(row: selectedPhotos, section: 0)
        collectionView(thumbnailCollectionView, didSelectItemAt: index)
        thumbnailCollectionView.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
        
    }
    
    
    @IBAction func doubleTap(_ sender: UITapGestureRecognizer) {
        detailImageView.contentMode = .scaleAspectFill
    }
    
}

extension DetailPhotoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let storeAssetsCount = setAsset(identifier).count
        return storeAssetsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailPhotoCell", for: indexPath) as? DetailPhotoCell ?? DetailPhotoCell()
        
        let photoAssets = self.setAsset(identifier)
        let photoAsset = photoAssets[indexPath.item]
        let options = PHImageRequestOptions()
        
        if let previousRequestID = cell.requestID {
            let manager = PHImageManager.default()
            manager.cancelImageRequest(previousRequestID)
        }
        
        cell.requestID = photoAsset.fetchImage(size: CGSize(width: 50.0, height: 50.0),
                                                        contentMode: .aspectFill,
                                                        options: options,
                                                        resultHandler: { (requestedImage) in
                                                            cell.thumbnailImageView.image = requestedImage
        })
        return cell
    }
}

extension DetailPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard pressedIndexPath != indexPath else { return }
        
        self.detailImageView.image = thumbnailImages[indexPath.item]
        
        self.detailImageView.contentMode = .scaleAspectFill
        self.zoomingScrollView.zoomScale = 1.0
        
        let assets = self.setAsset(identifier)
        let asset = assets[indexPath.item]
        selectedPhotos = indexPath.item
        pressedIndexPath = indexPath
        
        let options = PHImageRequestOptions()
        
        
        options.setImageRequestOptions(networkAccessAllowed: true, synchronous: false, deliveryMode: .opportunistic) { [weak self] (progress, _, _, _)-> Void in
            guard let thumbnailViewCell = self?.thumbnailCollectionView.cellForItem(at: indexPath) as? DetailPhotoCell else { return }
            DispatchQueue.main.async {
                guard self?.pressedIndexPath == indexPath else { return }
                self?.detailImageView.image = thumbnailViewCell.thumbnailImageView.image
                self?.loadingIndicatorView.startAnimating()
                
                let percent = 100 * progress
                let progressView: UIProgressView = .init()
                progressView.progressViewStyle = .bar
                progressView.tintColor = UIColor.black
                
                progressView.frame = CGRect.init(x: (self?.detailImageView.center.x)! - 100, y: (self?.detailImageView.center.y)!, width: 250, height: 250)
                self?.detailImageView.addSubview(progressView)
                
                progressView.setProgress(Float(percent), animated: true)
            }
        }
        
        DispatchQueue.global().async { [weak self] _ -> Void in
            asset.fetchFullSizeImage(options: options, resultHandler: { [weak self] (fetchedData) in
                guard let data = fetchedData else { return }
                DispatchQueue.main.async {
                    guard self?.pressedIndexPath == indexPath else { return }
                    self?.detailImageView.image = UIImage(data: data)
                    self?.loadingIndicatorView.stopAnimating()
                }
            })
        }
    }
}

extension DetailPhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.detailImageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        detailImageView.contentMode = .scaleAspectFit
    }
}
