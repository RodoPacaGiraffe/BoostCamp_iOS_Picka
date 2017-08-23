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
    @IBOutlet fileprivate var zoomingScrollView: UIScrollView!
    @IBOutlet fileprivate var detailImageView: UIImageView!
    @IBOutlet fileprivate var thumbnailCollectionView: UICollectionView!
    @IBOutlet private var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet private var panGestureRecognizer: UIPanGestureRecognizer!
    
    fileprivate var previousSelectedCell: DetailPhotoCell?
    private var moveToTempVCButtonItem: UIBarButtonItem?
    private var startPanGesturePoint: CGPoint = CGPoint()
    private var currentImageViewPosition: CGPoint = CGPoint()
    private var isInitialFetchImage: Bool = true
    var thumbnailImages: [UIImage] = []
    var selectedSectionAssets: [PHAsset] = []
    var photoDataSource: PhotoDataSource?
    var pressedIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    var identifier: String = "" {
        didSet {
            if identifier == "fromTemporaryViewController" {
                navigationItem.setRightBarButtonItems(nil, animated: false)
                panGestureRecognizer.isEnabled = false
            }
        }
    }
    
    var selectedPhotos: Int = 0 {
        didSet {
            if selectedPhotos < 0 {
                selectedPhotos += 1
            } else if selectedPhotos == selectedSectionAssets.count {
                selectedPhotos -= 1
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setFlowLayout()
        displayDetailViewSetting()
        setNavigationButtonItem()
        
        NotificationCenter.default.addObserver(self, selector: #selector (applyRemovedAssets(_:)),
                                               name: Constants.removedAssetsFromPhotoLibrary,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (updateBadge),
                                               name: Constants.requiredUpdatingBadge,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: Constants.removedAssetsFromPhotoLibrary,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: Constants.requiredUpdatingBadge,
                                                  object: nil)
    }
    
    @objc private func updateBadge() {
        guard let count = photoDataSource?.temporaryPhotoStore.photoAssets.count else { return }
        
        moveToTempVCButtonItem?.updateBadge(With: count)
    }
    
    @objc func applyRemovedAssets(_ notification: Notification) {
        guard let removedPhotoAssets = notification.userInfo?[Constants.removedPhotoAssets]
            as? [PHAsset] else { return }
        
        removedPhotoAssets.forEach {
            guard let index = selectedSectionAssets.index(of: $0) else { return }
            
            selectedSectionAssets.remove(at: index)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.thumbnailCollectionView.reloadSections(IndexSet(integer: 0))
            self?.moveToNextPhoto()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let count = photoDataSource?.temporaryPhotoStore.photoAssets.count else { return }
        moveToTempVCButtonItem?.updateBadge(With: count)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        detailImageView.layer.removeAllAnimations()
    }
    
    private func setFlowLayout() {
        guard let gesture = self.navigationController?.interactivePopGestureRecognizer else { return }
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
        flowLayout.itemSize.height = thumbnailCollectionView.bounds.height
        flowLayout.itemSize.width = flowLayout.itemSize.height
    }
    
    private func updatePhotoIndex(direction: UISwipeGestureRecognizerDirection) {
        switch direction {
        case UISwipeGestureRecognizerDirection.right:
            selectedPhotos -= 1
        case UISwipeGestureRecognizerDirection.left:
            selectedPhotos += 1
        default:
            break
        }
    }
    
    private func displayDetailViewSetting() {
        self.zoomingScrollView.minimumZoomScale = 1.0
        self.zoomingScrollView.maximumZoomScale = 6.0
        
        detailImageView.image = thumbnailImages.first
        
        if Bundle.main.preferredLocalizations.first == "ar" {
            thumbnailCollectionView.semanticContentAttribute = .forceRightToLeft
        }
        
        fetchFullSizeImage(from: pressedIndexPath)
        thumbnailCollectionView.selectItem(at: pressedIndexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    private func setTranslucentToNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    private func setNavigationButtonItem() {
        guard let count = photoDataSource?.temporaryPhotoStore.photoAssets.count else { return }
        
        moveToTempVCButtonItem = UIBarButtonItem.getUIBarbuttonItemincludedBadge(With: count)
        
        moveToTempVCButtonItem?.addButtonTarget(target: self,
                                                action: #selector (moveToTemporaryViewController),
                                                for: .touchUpInside)
        
        self.navigationItem.setRightBarButton(moveToTempVCButtonItem, animated: true)
        self.navigationItem.title = selectedSectionAssets.first?.creationDate?.toDateString()
    }
    
    @objc private func moveToTemporaryViewController() {
        performSegue(withIdentifier: "ModalRemovedPhotoVC", sender: self)
    }
    
    fileprivate func fetchFullSizeImage(from indexPath: IndexPath) {
        let options = PHImageRequestOptions()
        
        options.setImageRequestOptions(networkAccessAllowed: Constants.dataAllowed, synchronous: false, deliveryMode: .opportunistic) { [weak self] (progress, _, _, _) in
            DispatchQueue.main.async {
                guard let thumbnailViewCell = self?.thumbnailCollectionView.cellForItem(at: indexPath) as? DetailPhotoCell else { return }
                guard self?.pressedIndexPath == indexPath else { return }
                
                self?.detailImageView.image = thumbnailViewCell.thumbnailImageView.image
                
                if Constants.dataAllowed {
                    self?.loadingIndicatorView.startAnimating()
                }
            }
        }
        
        let photoAsset: PHAsset = selectedSectionAssets[indexPath.item]
        
        DispatchQueue.global().async { [weak self] _ -> Void in
            photoAsset.fetchFullSizeImage(options: options, resultHandler: { [weak self] data in
                if !Constants.dataAllowed {
                    guard let thumbnailViewCell = self?.thumbnailCollectionView.cellForItem(at: indexPath)
                        as? DetailPhotoCell else { return }
                    self?.detailImageView.image = thumbnailViewCell.thumbnailImageView.image
                }
                
                guard let fetchedData = data else { return }
                guard let detailVC = self else { return }
                
                DispatchQueue.main.async {
                    guard detailVC.pressedIndexPath == indexPath else { return }
                    
                    detailVC.loadingIndicatorView.stopAnimating()
                    
                    guard !detailVC.isInitialFetchImage else {
                        detailVC.detailImageView.image = UIImage(data: fetchedData)
                        detailVC.isInitialFetchImage = false
                        return
                    }
                
                    UIView.transition(with: detailVC.detailImageView,
                        duration: 0.2, options: .transitionCrossDissolve,
                        animations: {
                            self?.detailImageView.image = UIImage(data: fetchedData)
                    },  completion: nil)
                }
            })
        }
    }

    @IBAction private func deleteSelectPhotoButton(_ sender: UIButton) {
         moveToTrashAnimation()
    }
    
    @IBAction private func horizontalSwipeAction(_ sender: UISwipeGestureRecognizer) {
        updatePhotoIndex(direction: sender.direction)
        
        let index = IndexPath(row: selectedPhotos, section: 0)
        collectionView(thumbnailCollectionView, didSelectItemAt: index)
    }
    
    private func moveToNextPhoto() {
        guard !selectedSectionAssets.isEmpty else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        detailImageView.image = nil

        if selectedPhotos >= selectedSectionAssets.count - 1 {
            updatePhotoIndex(direction: .right)
        }
        
        let index = IndexPath(row: selectedPhotos, section: 0)
        collectionView(thumbnailCollectionView, didSelectItemAt: index)
    }
    
    @IBAction private func panGestureAction(_ sender: UIPanGestureRecognizer) {
        let location = sender.translation(in: self.view)
        
        switch sender.state {
        case .began:
            detailImageView.clipsToBounds = true
        case .changed:
            if location.y < -30 {
                setTranslucentToNavigationBar()
                detailImageView.frame.origin = CGPoint(x: self.detailImageView.frame.origin.x,
                                                     y: location.y)
                UIView.animate(withDuration: 0.5, animations: {
                    self.detailImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                })
            }
            if location.y > 30 {
                setTranslucentToNavigationBar()
                detailImageView.frame.origin = CGPoint(x: self.detailImageView.frame.origin.x,
                                                       y: location.y - 30)
                UIView.animate(withDuration: 0.5, animations: {
                    self.detailImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            }
        case .ended:
            guard (startPanGesturePoint.y - location.y) > view.bounds.height / 6 else {
                self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
                self.navigationController?.navigationBar.isTranslucent = false
                detailImageView.center = CGPoint(x: zoomingScrollView.center.x,
                                                 y: zoomingScrollView.center.y)
                UIView.animate(withDuration: 0.3, animations: {
                    self.detailImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
                break
            }
            
            moveToTrashAnimation()
        default:
            break
        }
    }
    
    private func moveToTrashAnimation() {
        guard let naviBarHeight = self.navigationController?.navigationBar.bounds.height else { return }
        
        let targetY = -(naviBarHeight / 2)
        var targetX: CGFloat {
            get {
                guard Bundle.main.preferredLocalizations.first != "ar" else {
                    return 20
                }
                
                return thumbnailCollectionView.bounds.width
            }
        }
        
        var rotateDegree: CGFloat {
            get {
                guard Bundle.main.preferredLocalizations.first != "ar" else {
                    return -45
                }
                
                return 45
            }
        }
        
        UIView.animate(withDuration: 0.2,
            animations: { [weak self] in
                guard let detailVC = self else { return }
                detailVC.detailImageView.center = CGPoint(x: targetX, y: targetY)
                detailVC.detailImageView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    .rotated(by: rotateDegree)
            }, completion: { [weak self] _ in
                guard let detailVC = self else { return }
                detailVC.navigationController?.navigationBar.isTranslucent = false
                detailVC.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
                detailVC.photoDataSource?.temporaryPhotoStore.insert(
                    photoAssets: [detailVC.selectedSectionAssets[detailVC.selectedPhotos]])
                detailVC.selectedSectionAssets.remove(at: detailVC.selectedPhotos)
                detailVC.detailImageView.center = detailVC.zoomingScrollView.center
                detailVC.detailImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                detailVC.thumbnailCollectionView.performBatchUpdates({
                    detailVC.thumbnailCollectionView.deleteItems(at: [detailVC.pressedIndexPath])
                }, completion: nil)
           
                detailVC.moveToNextPhoto()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ModalRemovedPhotoVC" else { return }
        guard let navigationController = segue.destination as? UINavigationController,
            let temporaryPhotoViewController = navigationController.topViewController
                as? TemporaryPhotoViewController else { return }
        
        temporaryPhotoViewController.photoDataSource = photoDataSource
    }
 
    @IBAction func dismissAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension DetailPhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedSectionAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailPhotoCell", for: indexPath)
            as? DetailPhotoCell ?? DetailPhotoCell()
        
        if identifier == "fromTemporaryViewController" {
            cell.detailDeleteButton.isHidden = true
        }
        
        if  indexPath == pressedIndexPath  {
            cell.select()
            selectedPhotos = pressedIndexPath.row
            previousSelectedCell = cell
        } else {
            cell.deSelect()
        }
        
        let photoAssets = selectedSectionAssets
        let photoAsset = photoAssets[indexPath.item]
        
        if let previousRequestID = cell.requestID {
            let manager = PHImageManager.default()
            manager.cancelImageRequest(previousRequestID)
        }
        
        cell.requestID = photoAsset.fetchImage(size: Constants.fetchImageSize,
            contentMode: .aspectFill, options: nil,
            resultHandler: { (requestedImage) in
                cell.thumbnailImageView.image = requestedImage
        })
        
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
        pressedIndexPath = indexPath
        detailImageView.contentMode = .scaleAspectFill
        zoomingScrollView.setZoomScale(1.0, animated: true)
        selectedPhotos = indexPath.item
        
        fetchFullSizeImage(from: indexPath)
        collectionView.selectItem(at: indexPath, animated: true,
                                  scrollPosition: .centeredHorizontally)
        
        self.navigationItem.title = selectedSectionAssets[indexPath.item].creationDate?.toDateString()
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

extension DetailPhotoViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
