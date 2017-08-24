//
//  DetailViewController.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

class DetailPhotoViewController: UIViewController {
    @IBOutlet var backButtonImage: UIBarButtonItem!
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
            if identifier == "fromTemporaryPhotoVC" {
                navigationItem.setRightBarButtonItems(nil, animated: false)
                panGestureRecognizer.isEnabled = false
            }
        }
    }
    
    var selectedPhotoIndex: Int = 0 {
        didSet {
            if selectedPhotoIndex < 0 {
                selectedPhotoIndex += 1
            } else if selectedPhotoIndex == selectedSectionAssets.count {
                selectedPhotoIndex -= 1
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
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            backButtonImage.image = UIImage(named: "rtlBack.png")
        }
    }
    
    private func updatePhotoIndex(direction: UISwipeGestureRecognizerDirection) {
        guard thumbnailCollectionView.cellForItem(at: pressedIndexPath) != nil else { return }
        
        switch direction {
        case UISwipeGestureRecognizerDirection.right:
            selectedPhotoIndex -= 1
        case UISwipeGestureRecognizerDirection.left:
            selectedPhotoIndex += 1
        default:
            break
        }
    }
    
    private func displayDetailViewSetting() {
        self.zoomingScrollView.minimumZoomScale = 1.0
        self.zoomingScrollView.maximumZoomScale = 6.0
        
        detailImageView.image = thumbnailImages.first
        
        fetchFullSizeImage(from: pressedIndexPath)
        thumbnailCollectionView.selectItem(at: pressedIndexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    private func setTranslucentToNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    private func setOpaqueToNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.isTranslucent = false
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

    @IBAction private func deletePhotoButtonTapped(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        photoDataSource?.temporaryPhotoStore.insert(
            photoAssets: [selectedSectionAssets[indexPath.row]])
        selectedSectionAssets.remove(at: indexPath.row)
        
        thumbnailCollectionView.performBatchUpdates({ [weak self] in
            self?.thumbnailCollectionView.deleteItems(at: [indexPath])
        }, completion: { [weak self] _ in
            guard let detailVC = self else { return }
            
            if detailVC.selectedPhotoIndex == indexPath.row {
                detailVC.moveToNextPhoto()
            } else if detailVC.selectedPhotoIndex > indexPath.row {
                detailVC.pressedIndexPath = IndexPath(row: detailVC.selectedPhotoIndex - 1,
                                                      section: 0)
            }
            
            detailVC.thumbnailCollectionView.reloadData()
        })
    }
    
    @IBAction private func horizontalSwipeAction(_ sender: UISwipeGestureRecognizer) {
        updatePhotoIndex(direction: sender.direction)
        
        let index = IndexPath(row: selectedPhotoIndex, section: 0)
        collectionView(thumbnailCollectionView, didSelectItemAt: index)
    }
    
    private func moveToNextPhoto() {
        guard !selectedSectionAssets.isEmpty else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        detailImageView.image = nil
        
        if selectedPhotoIndex > selectedSectionAssets.count - 1 {
            selectedPhotoIndex -= 1
            pressedIndexPath = IndexPath(row: selectedPhotoIndex, section: 0)
        }
        
        let index = IndexPath(row: selectedPhotoIndex, section: 0)
        thumbnailCollectionView.selectItem(at: index, animated: true,
                                  scrollPosition: .centeredHorizontally)
        
        if thumbnailCollectionView.cellForItem(at: pressedIndexPath) == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                self.collectionView(self.thumbnailCollectionView, didSelectItemAt: index)
            }
        } else {
            self.collectionView(self.thumbnailCollectionView, didSelectItemAt: index)
        }
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
                setOpaqueToNavigationBar()
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
                guard UIApplication.shared.userInterfaceLayoutDirection != .rightToLeft else {
                    return 20
                }
                
                return thumbnailCollectionView.bounds.width
            }
        }
        
        var rotateDegree: CGFloat {
            get {
                guard UIApplication.shared.userInterfaceLayoutDirection != .rightToLeft else {
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
                detailVC.setOpaqueToNavigationBar()
                detailVC.photoDataSource?.temporaryPhotoStore.insert(
                    photoAssets: [detailVC.selectedSectionAssets[detailVC.selectedPhotoIndex]])
                detailVC.selectedSectionAssets.remove(at: detailVC.selectedPhotoIndex)
                detailVC.detailImageView.center = detailVC.zoomingScrollView.center
                detailVC.detailImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                detailVC.thumbnailCollectionView.performBatchUpdates({
                    detailVC.thumbnailCollectionView.deleteItems(at: [detailVC.pressedIndexPath])
                }, completion: { _ in
                    detailVC.thumbnailCollectionView.reloadData()
                })
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
        
        if identifier == "fromTemporaryPhotoVC" {
            cell.detailDeleteButton.isHidden = true
        } else {
            cell.detailDeleteButton.tag = indexPath.row
        }
        
        if indexPath == pressedIndexPath {
            cell.select()
            selectedPhotoIndex = pressedIndexPath.row
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
            resultHandler: { requestedImage in
                cell.thumbnailImageView.image = requestedImage
        })
        
        return cell
    }
}

extension DetailPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let thumbnailViewCell = collectionView.cellForItem(at: indexPath)
            as? DetailPhotoCell else {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            return
        }
        
        previousSelectedCell?.deSelect()
        thumbnailViewCell.select()
        previousSelectedCell = thumbnailViewCell
        pressedIndexPath = indexPath
        selectedPhotoIndex = indexPath.item
        
        fetchFullSizeImage(from: indexPath)
        collectionView.selectItem(at: indexPath, animated: true,
                                  scrollPosition: .centeredHorizontally)
        
        self.navigationItem.title = selectedSectionAssets[indexPath.item].creationDate?.toDateString()
    }
}

extension DetailPhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return detailImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        zoomingScrollView.setZoomScale(1.0, animated: true)
    }
}

extension DetailPhotoViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.state == .changed {
            otherGestureRecognizer.require(toFail: gestureRecognizer)
        }
        
        return true
    }
}
