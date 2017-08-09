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
        
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name("reload"), object: nil)
        
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
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func reload() {
        tableView.reloadData()
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
        
        show(detailViewController, sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let windowWidth = self.view.window?.frame.width else { return CGFloat() }
        
        let cellHeight = (windowWidth - CGFloat(Constants.stackViewSpacing)) / CGFloat(Constants.maximumImageView)
        
        return cellHeight + 46.5
        
    }
}


