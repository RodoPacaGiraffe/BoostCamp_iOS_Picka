//
//  RemovedPhotoViewController.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

class TemporaryPhotoViewController: UIViewController {
    fileprivate enum SelectMode: String {
        case on = "Cancel"
        case off = "Choose"
    }
    
    @IBOutlet fileprivate var deleteSelectedButton: UIButton!
    @IBOutlet fileprivate var recoverSelectedButton: UIButton!
    @IBOutlet private var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var chooseButton: UIBarButtonItem!
    @IBOutlet private var buttonForEditStackView: UIStackView!
    @IBOutlet private var buttonForNormalStackView: UIStackView!
    
    private var originalNavigationPosition: CGPoint?
    private var originalPosition: CGPoint?
    private var currentTouchPosition: CGPoint?
    var photoDataSource: PhotoDataSource?
  
    fileprivate var selectMode: SelectMode = .off {
        didSet {
            toggleHiddenState(forViews: [buttonForEditStackView, buttonForNormalStackView])
            chooseButton.title = NSLocalizedString(selectMode.rawValue, comment: "")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionView()
        setCellSize()
        
        NotificationCenter.default.addObserver(self, selector: #selector (reloadData),
                                               name: Constants.requiredReload, object: nil)
    }
    
    private func setCollectionView() {
        collectionView.dataSource = photoDataSource
        collectionView.allowsMultipleSelection = true
        
        let bottomInset: CGFloat = collectionView.frame.maxY - buttonForNormalStackView.frame.origin.y
        
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: bottomInset, right: 0.0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: bottomInset, right: 0.0)
    }
    
    private func setCellSize() {
        let width = (collectionView.bounds.width / 4) - flowLayout.minimumLineSpacing * 2

        flowLayout.itemSize.width = width
        flowLayout.itemSize.height = width
    }
    
    private func toggleHiddenState(forViews views: [UIView]) {
        views.forEach {
            $0.isHidden = !$0.isHidden
        }
    }
    
    fileprivate func selectedPhotoAssets() -> [PHAsset] {
        guard let selectedItems = self.collectionView.indexPathsForSelectedItems else { return [] }
        guard let temporaryPhotoStore = self.photoDataSource?.temporaryPhotoStore else { return [] }
        
        var selectedPhotoAssets: [PHAsset] = []
        
        selectedItems.forEach {
            let selectedPhotoAsset = temporaryPhotoStore.photoAssets[$0.row]
            selectedPhotoAssets.append(selectedPhotoAsset)
        }
        
        return selectedPhotoAssets
    }
    
    @objc private func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    private func initSelection() {
        guard let selectedItems = collectionView.indexPathsForSelectedItems else {
            return
        }
        
        collectionView.reloadItems(at: selectedItems)
    }
    
    @IBAction func toggleSelectMode(_ sender: UIBarButtonItem) {
        if selectMode == .off {
            selectMode = .on
            if self.selectedPhotoAssets().isEmpty {
                recoverSelectedButton.isEnabled = false
                deleteSelectedButton.isEnabled = false
            }
        } else {
            selectMode = .off
            
            initSelection()
        }
    }
    
    @IBAction func recoverAll(_ sender: UIButton) {
        recoverAlertController(title: "Recover All Photos") { [weak self] _ in
            guard let temporaryPhotoStore = self?.photoDataSource?.temporaryPhotoStore else { return }
            
            let allRemovedPhotoAssets = temporaryPhotoStore.photoAssets
            temporaryPhotoStore.remove(photoAssets: allRemovedPhotoAssets)

            self?.collectionView.reloadSections(IndexSet(integer: 0))

            guard let navigationController = self?.presentingViewController
                as? UINavigationController else { return }
            
            NotificationCenter.default.post(name: Constants.requiredReload, object: nil)
            
            if navigationController.topViewController is ClassifiedPhotoViewController {
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.dismiss(animated: false) {
                    navigationController.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func recoverSelected(_ sender: UIButton) {
        recoverAlertController(title: "Recover Selected Photos") { [weak self] _ in
            guard let temporaryPhotoStore = self?.photoDataSource?.temporaryPhotoStore else { return }
            guard let temporaryVC = self else { return }
            
            temporaryPhotoStore.remove(photoAssets: temporaryVC.selectedPhotoAssets())
            
            temporaryVC.collectionView.reloadSections(IndexSet(integer: 0))
            
            guard let navigationController = temporaryVC.presentingViewController
                as? UINavigationController else { return }
            
            NotificationCenter.default.post(name: Constants.requiredReload, object: nil)
            
            if navigationController.topViewController is ClassifiedPhotoViewController {
                temporaryVC.dismiss(animated: true, completion: nil)
            } else {
                temporaryVC.dismiss(animated: false) {
                    navigationController.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func deleteAll(_ sender: UIButton) {
        guard let temporaryPhotoStore = photoDataSource?.temporaryPhotoStore else { return }
        
        temporaryPhotoStore.removePhotoFromLibrary(with: temporaryPhotoStore.photoAssets) { [weak self] in
            self?.collectionView.reloadSections(IndexSet(integer: 0))
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteSelected(_ sender: UIButton) {
        guard let temporaryPhotoStore = photoDataSource?.temporaryPhotoStore else { return }
        
        temporaryPhotoStore.removePhotoFromLibrary(with: selectedPhotoAssets()) { [weak self] in
            self?.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func recoverAlertController(title: String,
                                        completion: @escaping (UIAlertAction) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let recoverAction = UIAlertAction(title: NSLocalizedString(title, comment: ""),
                                          style: .default, handler: completion)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .destructive, handler: nil)
        
        alertController.addAction(recoverAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = UIColor.darkGray
       
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func slideToDismiss(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        let originalViewFrame = self.view.frame.origin
       
        switch sender.state {
        case .began:
            originalPosition = view.center
            originalNavigationPosition = navigationController?.navigationBar.center
            currentTouchPosition = sender.location(in: self.view)
        case .changed:
            if translation.y > 200 {
                UIView.animate(withDuration: 0.2, animations: { 
                    self.view.frame.origin = CGPoint(x: originalViewFrame.x,
                                                     y: translation.y + 64)
                    self.navigationController?.navigationBar.frame.origin = CGPoint(x: originalViewFrame.x,
                                                                                    y: translation.y + 20)
                })
            }
        case .ended:
            dismissWhenTouchesEnded(sender)
        default:
            break
        }
    }
    
    func dismissWhenTouchesEnded(_ sender: UIPanGestureRecognizer) {
        var originalViewFrame = self.view.frame.origin
        var originalNavigationBarFrame = self.navigationController?.navigationBar.frame.origin
        let translation = sender.translation(in: self.view)
        
        guard translation.y > 300  else {
            UIView.animate(withDuration: 0.2, animations: { [weak self] _ in
                guard let originalPosition = self?.originalPosition else { return }
                guard let originalNavigationPosition = self?.originalNavigationPosition else { return }
                
                self?.view.center = originalPosition
                self?.navigationController?.navigationBar.center = originalNavigationPosition
            })
            
            return
        }
        
        UIView.animate(withDuration: 0.2,
            animations: {
                originalViewFrame = CGPoint(x: originalViewFrame.x,
                                            y: self.view.frame.size.height)
                originalNavigationBarFrame = CGPoint(x: originalViewFrame.x,
                                                     y: self.view.frame.size.height)
        },
            completion: { [weak self] completed in
                guard completed == true else { return }
                
                self?.dismiss(animated: true, completion: nil)
        })
    }
}

extension TemporaryPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photoCell = collectionView.cellForItem(at: indexPath)
            as? TemporaryPhotoCell else { return }
        
        switch selectMode {
        case .on:
            deleteSelectedButton.isEnabled = true
            recoverSelectedButton.isEnabled = true
            photoCell.select()
        case .off:
            collectionView.deselectItem(at: indexPath, animated: true)
            guard let temporaryPhotoStore = photoDataSource?.temporaryPhotoStore else { return }
            guard let detailViewController = storyboard?.instantiateViewController(withIdentifier:  "detailViewController") as? DetailPhotoViewController else { return }
            
            detailViewController.selectedSectionAssets = temporaryPhotoStore.photoAssets
            detailViewController.identifier = "fromTemporaryViewController"
            
            guard let selectedThumbnailImage = photoCell.thumbnailImageView.image else { return }
            detailViewController.thumbnailImages.append(selectedThumbnailImage)
            detailViewController.pressedIndexPath = indexPath
            
            detailViewController.navigationItem.title = temporaryPhotoStore.photoAssets[indexPath.item]
                .creationDate?.toDateString()
            
            show(detailViewController, sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let photoCell = collectionView.cellForItem(at: indexPath)
            as? TemporaryPhotoCell ?? TemporaryPhotoCell()
        photoCell.deSelect()
        
        if self.selectedPhotoAssets().isEmpty {
            deleteSelectedButton.isEnabled = false
            recoverSelectedButton.isEnabled = false
        }
    }
}

extension TemporaryPhotoViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

