//
//  PhotoViewController.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 4..
//  Copyright © 2017년 임성훈. All rights reserved.
//

import UIKit
import Photos

class ClassifiedPhotoViewController: UIViewController {
    //MARK: Properties
    @IBOutlet var tableView: UITableView!
    
    let photoDataSource = PhotoDataSource()
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = photoDataSource
        tableView.delegate = self
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
}



