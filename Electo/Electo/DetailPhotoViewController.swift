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
    var selectedSectionAsset: Int = .init()
    var photoStore: PhotoStore?
    var selectedPhotos: Int = 0
    var pressedIndexPath: IndexPath?
    var thumbnailFetchReqeustID: PHImageRequestID?
    
    
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
    
    @IBAction func doubleTap(_ sender: UITapGestureRecognizer) {
        detailImageView.contentMode = .scaleAspectFill
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
        let options = PHImageRequestOptions()
        
        if let previousRequestID = thumbnailFetchReqeustID {
            let manager = PHCachingImageManager.default()
            manager.cancelImageRequest(previousRequestID)
        }
        
        thumbnailFetchReqeustID = photoAsset?.fetchImage(size: CGSize(width: 50.0, height: 50.0),
                               contentMode: .aspectFit,
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
        
        let photoAsset = photoStore?.classifiedPhotoAssets[selectedSectionAsset][indexPath.item]
        selectedPhotos = indexPath.item
        pressedIndexPath = indexPath
        
        let options = PHImageRequestOptions()

        options.setImageRequestOptions(networkAccessAllowed: true, synchronous: true, deliveryMode: .opportunistic) { [weak self] _ -> Void in
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
            photoAsset?.fetchFullSizeImage(options: options, resultHandler: { [weak self] (fetchedData) in
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
