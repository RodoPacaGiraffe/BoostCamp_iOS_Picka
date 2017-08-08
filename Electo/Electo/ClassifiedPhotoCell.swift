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
    
    var cellImages: [UIImage] = .init() {
        didSet {
            addPhotoImagesToStackView(photoImages: cellImages)
        }
    }
    
    func update(date: String, location: String?) {
        dateLabel.text = date
        locationLabel.text = location
    }
    
    func addPhotoImagesToStackView(photoImages: [UIImage]) {
        for _ in 0..<4 {
            let imageView: UIImageView = .init()
            imageStackView.addArrangedSubview(imageView)
        }
        
        if photoImages.count < 4 {
            for index in photoImages.indices {
                guard let subImageView = imageStackView.arrangedSubviews[index] as? UIImageView else { break }
                subImageView.image = photoImages[index]
            }
        } else {
            for index in 0..<4 {
                guard let subImageView = imageStackView.arrangedSubviews[index] as? UIImageView else { break }
                subImageView.image = photoImages[index]
            }
        }
    }
    
    func clearStackView() {
        imageStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
}

