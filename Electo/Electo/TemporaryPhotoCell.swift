//
//  RemovedPhotoCell.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

class TemporaryPhotoCell: UICollectionViewCell {
    @IBOutlet weak var removedImageView: UIImageView!
    @IBOutlet weak var checkedImageView: UIImageView!
    
    func addRemovedImage(removedPhotoImage: UIImage) {
        removedImageView.image = removedPhotoImage
    }
    
    func select() {
        removedImageView.alpha = 0.5
        checkedImageView.isHidden = false
    }
    
    func deSelect() {
        removedImageView.alpha = 1.0
        checkedImageView.isHidden = true
    }
}
