//
//  DetailPhotoCell.swift
//  Electo
//
//  Created by byung-soo kwon on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

class DetailPhotoCell: UICollectionViewCell {
    @IBOutlet var thumbnailImageView: UIImageView!
    
    var requestID: PHImageRequestID? = .init()
}
