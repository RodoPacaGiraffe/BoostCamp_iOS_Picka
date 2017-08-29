//
//  DetailViewController.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

fileprivate struct Constants {
    struct ZoomingScrollView {
        static let minimumZoomScale: CGFloat = 1.0
        static let maximumZoomScale: CGFloat = 6.0
    }
    
    struct DetailImageViewTransition {
        static let duration: TimeInterval = 0.15
    }
    
    struct DetailImageViewPanGesture {
        static let originalScale: CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        static let targetScale: CGAffineTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        static let duration: TimeInterval = 0.3
        static let activateBounds: CGFloat = 30
    }
    
    struct MoveToTrashAnimation {
        static let targetScale: CGAffineTransform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        static let originalScale: CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        static let duration: TimeInterval = 0.2
    }
    
    struct CellIdentifier {
        static let detailPhotoCell: String = "detailPhotoCell"
    }
    
    static let targetScaleForRTL: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
}

class DetailPhotoViewController: UIViewController {
    
    @IBOutlet private var backButtonImage: UIBarButtonItem!
    @IBOutlet fileprivate var zoomingScrollView: UIScrollView!
    @IBOutlet fileprivate var detailImageView: UIImageView!
    @IBOutlet fileprivate var thumbnailCollectionView: UICollectionView!
    @IBOutlet fileprivate var instructionLabel: UILabel!
    @IBOutlet private var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet private var panGestureRecognizer: UIPanGestureRecognizer!
    
    fileprivate var previousSelectedCell: DetailPhotoCell?
    private var moveToTempVCButtonItem: UIBarButtonItem?
    private var panGestureTranckingIsActivate: Bool = false
    private var isInitialFetchImage: Bool = true
    var selectedSectionAssets: [PHAsset] = []
    var photoDataSource: PhotoDataSource?
    
    var pressedIndexPath: IndexPath = IndexPath() {
        didSet {
            if pressedIndexPath.item < 0 {
                pressedIndexPath.item += 1
            } else if pressedIndexPath.item == selectedSectionAssets.count {
                pressedIndexPath.item -= 1
            }
        }
    }
    
    var identifier: String = "" {
        didSet {
            if identifier == PreviousVCIdentifier.fromTemporaryPhotoVC {
                navigationItem.setRightBarButtonItems(nil, animated: false)
                panGestureRecognizer.isEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setFlowLayout()
        displayDetailViewSetting()
        setNavigationButtonItem()
        setNotificationObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let count = photoDataSource?.temporaryPhotoStore.photoAssets.count else { return }
        moveToTempVCButtonItem?.updateBadge(with: count)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        detailImageView.layer.removeAllAnimations()
    }
    
    @objc private func updateBadge() {
        guard let count = photoDataSource?.temporaryPhotoStore.photoAssets.count else { return }
        moveToTempVCButtonItem?.updateBadge(with: count)
    }
    
    @objc func applyRemovedAssets(_ notification: Notification) {
        guard let removedPhotoAssets = notification.userInfo?[NotificationUserInfoKey.removedPhotoAssets]
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
    
    private func setFlowLayout() {
        guard let gesture = self.navigationController?.interactivePopGestureRecognizer else { return }
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
        
        flowLayout.itemSize.height = thumbnailCollectionView.bounds.height
        flowLayout.itemSize.width = flowLayout.itemSize.height
    }
    
    private func setNavigationButtonItem() {
        guard let count = photoDataSource?.temporaryPhotoStore.photoAssets.count else { return }
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            backButtonImage.image = #imageLiteral(resourceName: "rtlBack")
        }
        
        moveToTempVCButtonItem = UIBarButtonItem.getUIBarbuttonItemincludedBadge(with: count)
        moveToTempVCButtonItem?.addButtonTarget(target: self,
                                                action: #selector (moveToTemporaryViewController),
                                                for: .touchUpInside)
        self.navigationItem.setRightBarButton(moveToTempVCButtonItem, animated: true)
        self.navigationItem.title = selectedSectionAssets.first?.creationDate?.toDateString()
    }
    
    private func displayDetailViewSetting() {
        zoomingScrollView.minimumZoomScale = Constants.ZoomingScrollView.minimumZoomScale
        zoomingScrollView.maximumZoomScale = Constants.ZoomingScrollView.maximumZoomScale
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            thumbnailCollectionView.transform = Constants.targetScaleForRTL
        }
        
        fetchFullSizeImage(from: pressedIndexPath)
        thumbnailCollectionView.selectItem(at: pressedIndexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    private func setNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector (applyRemovedAssets(_:)),
                                               name: NotificationName.removedAssetsFromPhotoLibrary,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (updateBadge),
                                               name: NotificationName.requiredUpdatingBadge,
                                               object: nil)
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
    
    fileprivate func fetchFullSizeImage(from indexPath: IndexPath) {
        let thumnailFetchOption = PHImageRequestOptions()
        thumnailFetchOption.setImageRequestOptions(networkAccessAllowed: false, synchronous: true, deliveryMode: .opportunistic, progressHandler: nil)
        selectedSectionAssets[indexPath.item].fetchImage(
            size: SettingConstants.fetchImageSize,
            contentMode: .aspectFill,
            options: thumnailFetchOption,
            resultHandler: { [weak self] requestedImage in
                self?.detailImageView.image = requestedImage
        })
        
        let fullSizeFetchOptions = PHImageRequestOptions()
        fullSizeFetchOptions.setImageRequestOptions(
        networkAccessAllowed: SettingConstants.networkDataAllowed,
        synchronous: false,
        deliveryMode: .opportunistic,
        progressHandler: { [weak self] (progress, _, _, _) in
            DispatchQueue.main.async {
                guard let detailVC = self else { return }
                guard detailVC.pressedIndexPath == indexPath else { return }
                
                if SettingConstants.networkDataAllowed {
                    self?.loadingIndicatorView.startAnimating()
                }
            }
        })
        
        let photoAsset: PHAsset = selectedSectionAssets[indexPath.item]
        photoAsset.fetchFullSizeImage(options: fullSizeFetchOptions, resultHandler: { [weak self] data in
            guard let fetchedData = data else { return }
            guard let detailVC = self else { return }
            guard detailVC.pressedIndexPath == indexPath else { return }
            detailVC.loadingIndicatorView.stopAnimating()
            
            guard !detailVC.isInitialFetchImage else {
                detailVC.detailImageView.image = UIImage(data: fetchedData)
                detailVC.isInitialFetchImage = false
                return
            }
            
            detailVC.transitionImageView(with: UIImage(data: fetchedData))
        })
    }
    
    private func transitionImageView(with transitionImage: UIImage?) {
        UIView.transition(with: detailImageView,
            duration: Constants.DetailImageViewTransition.duration,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.detailImageView.image = transitionImage
        },  completion: nil)
    }
    
    private func moveToNextPhoto() {
        guard !selectedSectionAssets.isEmpty else {
            detailImageView.image = nil
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if pressedIndexPath.item > selectedSectionAssets.count - 1 {
            pressedIndexPath.item -= 1
        }
        
        let index = IndexPath(row: pressedIndexPath.item, section: 0)
        collectionView(thumbnailCollectionView, didSelectItemAt: index)
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
        
        UIView.animate(withDuration: Constants.MoveToTrashAnimation.duration,
            animations: { [weak self] in
                guard let detailVC = self else { return }
                detailVC.detailImageView.center = CGPoint(x: targetX, y: targetY)
                detailVC.detailImageView.transform = Constants.MoveToTrashAnimation.targetScale.rotated(by: rotateDegree)
            }, completion: { [weak self] _ in
                guard let detailVC = self else { return }
                detailVC.setOpaqueToNavigationBar()
                detailVC.photoDataSource?.temporaryPhotoStore.insert(
                    photoAssets: [detailVC.selectedSectionAssets[detailVC.pressedIndexPath.item]])
                detailVC.selectedSectionAssets.remove(at: detailVC.pressedIndexPath.item)
                detailVC.detailImageView.center = detailVC.zoomingScrollView.center
                detailVC.detailImageView.transform = Constants.MoveToTrashAnimation.originalScale
                
                detailVC.thumbnailCollectionView.performBatchUpdates({
                    detailVC.thumbnailCollectionView.deleteItems(at: [detailVC.pressedIndexPath])
                }, completion: { _ in
                    detailVC.thumbnailCollectionView.reloadData()
                })
                
                detailVC.moveToNextPhoto()
        })
    }
    
    @IBAction private func horizontalSwipeAction(_ sender: UISwipeGestureRecognizer) {
        guard thumbnailCollectionView.cellForItem(at: pressedIndexPath) != nil else { return }
        
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.right:
            guard pressedIndexPath.item != 0 else { return }
            pressedIndexPath.item -= 1
        case UISwipeGestureRecognizerDirection.left:
            guard pressedIndexPath.item != selectedSectionAssets.count - 1 else { return }
            pressedIndexPath.item += 1
        default:
            break
        }
        
        let index = IndexPath(row: pressedIndexPath.item, section: 0)
        collectionView(thumbnailCollectionView, didSelectItemAt: index)
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
            
            if detailVC.pressedIndexPath.item == indexPath.row {
                detailVC.moveToNextPhoto()
            } else if detailVC.pressedIndexPath.item > indexPath.row {
                detailVC.pressedIndexPath = IndexPath(row: detailVC.pressedIndexPath.item - 1, section: 0)
            }
            
            detailVC.thumbnailCollectionView.reloadData()
        })
    }
    
    @IBAction private func panToDeleteGestureAction(_ sender: UIPanGestureRecognizer) {
        let location = sender.translation(in: self.view)
        
        switch sender.state {
        case .changed:
            if location.y < -Constants.DetailImageViewPanGesture.activateBounds {
                panGestureTranckingIsActivate = true
                setTranslucentToNavigationBar()
                detailImageView.frame.origin = CGPoint(x: self.detailImageView.frame.origin.x,
                                                       y: location.y)
                UIView.animate(withDuration: Constants.DetailImageViewPanGesture.duration, animations: {
                    self.detailImageView.transform = Constants.DetailImageViewPanGesture.targetScale
                })
            } else if location.y > 0 && panGestureTranckingIsActivate == true {
                detailImageView.frame.origin = CGPoint(x: self.detailImageView.frame.origin.x,
                                                       y: location.y - Constants.DetailImageViewPanGesture.activateBounds)
                UIView.animate(withDuration: Constants.DetailImageViewPanGesture.duration, animations: {
                    self.detailImageView.transform = Constants.DetailImageViewPanGesture.originalScale
                })
            }
        case .ended:
            panGestureTranckingIsActivate = false
            
            guard -location.y > view.bounds.height / 6 else {
                setOpaqueToNavigationBar()
                detailImageView.center = CGPoint(x: zoomingScrollView.center.x,
                                                 y: zoomingScrollView.center.y)
                UIView.animate(withDuration: Constants.DetailImageViewPanGesture.duration, animations: {
                    self.detailImageView.transform = Constants.DetailImageViewPanGesture.originalScale
                })
                break
            }
            
            moveToTrashAnimation()
        default:
            break
        }
    }
    
    @objc private func moveToTemporaryViewController() {
        performSegue(withIdentifier: SegueIdentifier.modalTemporaryPhotoVC, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == SegueIdentifier.modalTemporaryPhotoVC else { return }
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
        let detailPhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifier.detailPhotoCell, for: indexPath)
            as? DetailPhotoCell ?? DetailPhotoCell()
        
        if identifier == PreviousVCIdentifier.fromTemporaryPhotoVC {
            detailPhotoCell.hideDeleteButton()
            instructionLabel.isHidden = true
        } else {
            detailPhotoCell.setTagToDeleteButton(with: indexPath.row)
        }
        
        if indexPath == pressedIndexPath {
            detailPhotoCell.select()
            previousSelectedCell = detailPhotoCell
        } else {
            detailPhotoCell.deSelect()
        }
        
        let photoAsset = selectedSectionAssets[indexPath.item]
        
        if let previousRequestID = detailPhotoCell.requestID {
            CachingImageManager.shared.cancelImageRequest(previousRequestID)
        }
        
        let requestID = photoAsset.fetchImage(size: SettingConstants.fetchImageSize,
            contentMode: .aspectFill, options: nil,
            resultHandler: { requestedImage in
                detailPhotoCell.setThumbnailImage(requestedImage)
        })
        
        detailPhotoCell.setRequestID(requestID)
        
        return detailPhotoCell
    }
}

extension DetailPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailPhotoCell = collectionView.cellForItem(at: indexPath)
            as? DetailPhotoCell else {
            fetchFullSizeImage(from: indexPath)
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            return
        }
        
        pressedIndexPath = indexPath
        previousSelectedCell?.deSelect()
        detailPhotoCell.select()
        previousSelectedCell = detailPhotoCell
        
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
        zoomingScrollView.setZoomScale(Constants.ZoomingScrollView.minimumZoomScale, animated: true)
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
