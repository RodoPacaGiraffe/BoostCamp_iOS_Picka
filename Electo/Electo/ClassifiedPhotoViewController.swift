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
                
                let removedAssetsFromLibrary = self?.photoDataSource.photoStore.applyUnarchivedPhotoAssets(unarchivedPhotoAssets: unarchivedPhotoAssets)
                
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
            let removedPhotoViewController = navigationController.topViewController
                as? TemporaryPhotoViewController else { return }
        
        removedPhotoViewController.photoDataSource = photoDataSource
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
        detailViewController.selectedRow = indexPath.row
        detailViewController.photoStore = photoDataSource.photoStore
        
        let selectedCell = tableView.cellForRow(at: indexPath) as? ClassifiedPhotoCell ?? ClassifiedPhotoCell.init()
        detailViewController.thumbnailImages = selectedCell.cellImages
        
        show(detailViewController, sender: self)
        
        
    }
}


