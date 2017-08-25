//
//  RemovedPhotoCell.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static let selectedImageViewAlpha: CGFloat = 0.5
    static let deselectedImageViewAlpha: CGFloat = 1.0
}

class TemporaryPhotoCell: UICollectionViewCell {
    @IBOutlet private var thumbnailImageView: UIImageView!
    @IBOutlet private var checkImageView: UIImageView!
    
    func setThumbnailPhotoImage(thumbnailPhotoImage: UIImage) {
        thumbnailImageView.image = thumbnailPhotoImage
    }
    
    override func prepareForReuse() {
        deSelect()
    }
    
    func select() {
        thumbnailImageView.alpha = Constants.selectedImageViewAlpha
        checkImageView.isHidden = false
        self.isSelected = true
    }
    
    func deSelect() {
        thumbnailImageView.alpha = Constants.deselectedImageViewAlpha
        checkImageView.isHidden = true
        self.isSelected = false
    }
}
