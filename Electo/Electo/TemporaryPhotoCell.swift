//
//  RemovedPhotoCell.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

class TemporaryPhotoCell: UICollectionViewCell {
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var checkedImageView: UIImageView!
    
    func addRemovedImage(removedPhotoImage: UIImage) {
        thumbnailImageView.image = removedPhotoImage
    }
    
    override func prepareForReuse() {
        deSelect()
    }
    
    func select() {
        thumbnailImageView.alpha = 0.5
        checkedImageView.isHidden = false
        self.isSelected = true
    }
    
    func deSelect() {
        thumbnailImageView.alpha = 1.0
        checkedImageView.isHidden = true
        self.isSelected = false
    }
}
