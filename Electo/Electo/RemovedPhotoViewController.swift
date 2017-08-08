//
//  RemovedPhotoViewController.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

class RemovedPhotoViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    var photoDataSource: PhotoDataSource?

    override func viewDidLoad() {
        collectionView.dataSource = photoDataSource
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension RemovedPhotoViewController: UICollectionViewDelegate {
    
}
