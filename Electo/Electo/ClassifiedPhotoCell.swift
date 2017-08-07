//
//  ImageCell.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 5..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

class ClassifiedPhotoCell: UITableViewCell {
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet weak var imageStackView: UIStackView!
    
    func update(date: String, location: String?) {
        dateLabel.text = date
        locationLabel.text = location
    }
    
    func addPhotoImagesToStackView(photoImages: UIImage) {
        imageStackView.addArrangedSubview(UIImageView(image: photoImages))
    }
    
    func clearStackView() {
        imageStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
}

