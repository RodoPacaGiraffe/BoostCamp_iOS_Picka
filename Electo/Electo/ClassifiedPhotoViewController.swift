//
//  PhotoViewController.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 4..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

class ClassifiedPhotoViewController: UIViewController {
    //MARK: Properties
    @IBOutlet var tableView: UITableView!
    
    var photoDataSource: PhotoDataSource = PhotoDataSource()
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = photoDataSource
        
        requestAuthorization()
        
        NotificationCenter.default.addObserver(self, selector: #selector (reloadData),
                                               name: Constants.requiredReload, object: nil)
    }
    
    private func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization {
            [weak self] (authorizationStatus) -> Void in
            guard authorizationStatus == .authorized else { return }
            
            DispatchQueue.global().sync {
                self?.photoDataSource.photoStore.fetchPhotoAsset()
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            
            guard let path = Constants.archiveURL?.path else { return }
            
            DispatchQueue.global().sync {
                guard let archivedtemporaryPhotoStore = NSKeyedUnarchiver.unarchiveObject(withFile: path)
                    as? TemporaryPhotoStore else { return }
                
                self?.photoDataSource.temporaryPhotoStore = archivedtemporaryPhotoStore
                self?.photoDataSource.temporaryPhotoStore.fetchPhotoAsset()
    
                let unarchivedPhotoAssets = self?.photoDataSource.temporaryPhotoStore.photoAssets
                
                let removedAssetsFromLibrary = self?.photoDataSource.photoStore.applyUnarchivedPhoto(
                    assets: unarchivedPhotoAssets)
                
                if let photoAssets = removedAssetsFromLibrary {
                    self?.photoDataSource.temporaryPhotoStore.remove(
                        photoAssets: photoAssets, isPerformDelegate: false)
                }
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ModalRemovedPhotoVC" else { return }
        guard let navigationController = segue.destination as? UINavigationController,
            let temporaryPhotoViewController = navigationController.topViewController
                as? TemporaryPhotoViewController else { return }
        
        temporaryPhotoViewController.photoDataSource = photoDataSource
    }
    
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension ClassifiedPhotoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let photoCell = cell as? ClassifiedPhotoCell else {
            print("cell is not a photoCell")
            return
        }
        
        photoCell.clearStackView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier:  "detailViewController") as? DetailPhotoViewController else { return }
        detailViewController.selectedSection = indexPath.section
        detailViewController.photoStore = photoDataSource.photoStore
        
        let selectedCell = tableView.cellForRow(at: indexPath) as? ClassifiedPhotoCell ?? ClassifiedPhotoCell.init()
        detailViewController.thumbnailImages = selectedCell.cellImages
        
        show(detailViewController, sender: self)
        
        
    }
}


