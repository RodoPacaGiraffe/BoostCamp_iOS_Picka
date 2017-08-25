//
//  DetailPhotoCell.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

fileprivate struct Constants {
    static let selectedImageViewAlpha: CGFloat = 0.5
    static let deselectedImageViewAlpha: CGFloat = 1.0
}

class DetailPhotoCell: UICollectionViewCell {
    @IBOutlet private var thumbnailImageView: UIImageView!
    @IBOutlet private var detailDeleteButton: UIButton!
    
    private(set) var requestID: PHImageRequestID?
    
    override func prepareForReuse() {
        deSelect()
    }
    
    func select() {
        thumbnailImageView.alpha = Constants.selectedImageViewAlpha
        self.isSelected = true
    }
    
    func deSelect() {
        thumbnailImageView.alpha = Constants.deselectedImageViewAlpha
        self.isSelected = false
    }
}
