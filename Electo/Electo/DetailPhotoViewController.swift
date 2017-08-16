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
    

    var photoStore: PhotoStore?
    var photoAssets: [PHAsset] = .init()
    var thumbnailImages: [UIImage] = .init()
    var selectedSectionAssets: [PHAsset] = []
    var selectedIndexPath: IndexPath = IndexPath()
    var pressedIndexPath: IndexPath = IndexPath()
    var selectedPhotos: Int = 0
    var pressedIndexPath: IndexPath = .init()
    var previousSelectedCell: DetailPhotoCell?
    var identifier: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayDetailViewSetting()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(zoomingScrollView.zoomScale)
    }
    
    func getAsset(from identifier: String) -> [PHAsset] {
        switch identifier {
        case "fromTemporaryViewController":
            return selectedSectionAssets
        default:
            guard let assets = photoStore?.classifiedPhotoAssets[
                selectedIndexPath.section].photoAssetsArray[selectedIndexPath.row] else { return [] }
            
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
            let count = getAsset(from: identifier).count
            selectedPhotos += 1
            if selectedPhotos == count {
                selectedPhotos -= 1
                return
            }
        default:
            return
        }
    }
    
    func displayDetailViewSetting() {
        self.zoomingScrollView.minimumZoomScale = 1.0
        self.zoomingScrollView.maximumZoomScale = 6.0
        
        self.tabBarController?.tabBar.isHidden = true
        photoAssets = setAsset(identifier)
        detailImageView.image = thumbnailImages.first
        
        fetchFullSizeImage(from: pressedIndexPath)
        thumbnailCollectionView.selectItem(at: pressedIndexPath, animated: true, scrollPosition: .centeredHorizontally)
        
        doubleTapRecognizer.numberOfTapsRequired = Constants.numberOfTapsRequired
    }
    
    func fetchFullSizeImage(from indexPath: IndexPath) {
        let options = PHImageRequestOptions()
        options.setImageRequestOptions(networkAccessAllowed: true, synchronous: false, deliveryMode: .opportunistic) { [weak self] (progress, _, _, _)-> Void in
            DispatchQueue.main.async {
                guard let thumbnailViewCell = self?.thumbnailCollectionView.cellForItem(at: indexPath) as? DetailPhotoCell else { return }

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
        
        let photoAsset: PHAsset = photoAssets[indexPath.item]
        DispatchQueue.global().async { [weak self] _ -> Void in
            photoAsset.fetchFullSizeImage(options: options, resultHandler: { [weak self] (fetchedData) in
                guard let data = fetchedData else { return }
                DispatchQueue.main.async {
                    self?.detailImageView.image = UIImage(data: data)
                    self?.loadingIndicatorView.stopAnimating()
                }
            })
        }
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
        self.zoomingScrollView.setZoomScale(1.0, animated: true)
        self.detailImageView.contentMode = .scaleAspectFill
    }
}

extension DetailPhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let storeAssetsCount = getAsset(from: identifier).count
        return storeAssetsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailPhotoCell", for: indexPath) as? DetailPhotoCell ?? DetailPhotoCell()
        

        let photoAssets = self.getAsset(from: identifier)
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
        
        if previousSelectedCell == nil {
            cell.select()
            previousSelectedCell = cell
        }
        
        return cell
    }
}

extension DetailPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let thumbnailViewCell = collectionView.cellForItem(at: indexPath)
            as? DetailPhotoCell else { return }
    
        previousSelectedCell?.deSelect()
        
        thumbnailViewCell.select()
        previousSelectedCell = thumbnailViewCell
        
        self.detailImageView.contentMode = .scaleAspectFill
        self.zoomingScrollView.setZoomScale(1.0, animated: true)
        

        let assets = self.getAsset(from: identifier)
        let asset = assets[indexPath.item]
        selectedPhotos = indexPath.item
        
        fetchFullSizeImage(from: indexPath)
    }
}

extension DetailPhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.detailImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.zoomingScrollView.setZoomScale(1.0, animated: true)
    }
}
