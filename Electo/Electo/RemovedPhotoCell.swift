//
//  RemovedPhotoCell.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

class RemovedPhotoCell: UICollectionViewCell {
    @IBOutlet var removedImageView: UIImageView!
    
    func addRemovedImage(removedPhotoImage: UIImage) {
        removedImageView.image = removedPhotoImage
    }
}
