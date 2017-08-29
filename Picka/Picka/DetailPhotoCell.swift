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
    struct ThumnailImageView {
        static let alphaForSelected: CGFloat = 0.5
        static let alphaForDeselected: CGFloat = 1.0
        static let targetScaleForRTL: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
}

class DetailPhotoCell: UICollectionViewCell {
    @IBOutlet private var thumbnailImageView: UIImageView!
    @IBOutlet private var deleteButton: UIButton!
    
    private(set) var requestID: PHImageRequestID?
    
    override func prepareForReuse() {
        deSelect()
    }
    
    func select() {
        thumbnailImageView.alpha = Constants.ThumnailImageView.alphaForSelected
        self.isSelected = true
    }
    
    func deSelect() {
        thumbnailImageView.alpha = Constants.ThumnailImageView.alphaForDeselected
        self.isSelected = false
    }
    
    func hideDeleteButton() {
        deleteButton.isHidden = true
    }
    
    func setTagToDeleteButton(with tag: Int) {
        deleteButton.tag = tag
    }
    
    func setRequestID(_ requestID: PHImageRequestID) {
        self.requestID = requestID
    }
    
    func setThumbnailImage(_ thumbnailImage: UIImage?) {
        thumbnailImageView.image = thumbnailImage
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            convertImageViewToRTL()
        }
    }
    
    private func convertImageViewToRTL() {
        thumbnailImageView.transform = Constants.ThumnailImageView.targetScaleForRTL
    }
}
