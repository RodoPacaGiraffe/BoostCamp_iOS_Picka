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
    
    var photoDataSource: PhotoDataSource?
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name("reload"), object: nil)
        
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization {
            [weak self] (authorizationStatus) -> Void in
            guard authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                self?.photoDataSource = PhotoDataSource()
                self?.tableView.dataSource = self?.photoDataSource
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reload()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc private func reload() {
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ModalRemovedPhotoVC" else { return }
        guard let navigationController = segue.destination as? UINavigationController,
            let removedPhotoViewController = navigationController.topViewController
                as? RemovedPhotoViewController else { return }
        
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
        detailViewController.selectedSectionAsset = indexPath.section
        detailViewController.photoStore = photoDataSource?.photoStore
        
        let selectedCell = tableView.cellForRow(at: indexPath) as? ClassifiedPhotoCell ?? ClassifiedPhotoCell.init()
        detailViewController.thumbnailImages = selectedCell.cellImages
        
        show(detailViewController, sender: self)
        
        
    }
}


