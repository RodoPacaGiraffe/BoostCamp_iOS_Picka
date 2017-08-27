//
//  RemovedPhotoCell.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    struct ThumnailImageView {
        static let alphaForSelected: CGFloat = 0.5
        static let alphaForDeselected: CGFloat = 1.0
    }
}

class TemporaryPhotoCell: UICollectionViewCell {
    @IBOutlet private var thumbnailImageView: UIImageView!
    @IBOutlet private var checkImageView: UIImageView!
    
    func setThumbnailImage(thumbnailImage: UIImage?) {
        thumbnailImageView.image = thumbnailImage
    }
    
    override func prepareForReuse() {
        deSelect()
    }
    
    func select() {
        thumbnailImageView.alpha = Constants.ThumnailImageView.alphaForSelected
        checkImageView.isHidden = false
        self.isSelected = true
    }
    
    func deSelect() {
        thumbnailImageView.alpha = Constants.ThumnailImageView.alphaForDeselected
        checkImageView.isHidden = true
        self.isSelected = false
    }
}
