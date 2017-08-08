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
    
    func addPhotoImagesToStackView(photoImages: [UIImage?]) {
        let imageView: UIImageView = .init()
        guard let windowWidth = window?.frame.width else { return }
        if windowWidth > 70 {
            for index in 0..<5 {
                imageStackView.addArrangedSubview(imageView)
                guard let imageView = imageStackView.subviews[index] as? UIImageView else { return }
                imageView.image = photoImages[index]
            }
        } else {
            for index in 0..<4 {
                imageStackView.addArrangedSubview(imageView)
                guard let imageView = imageStackView.subviews[index] as? UIImageView else { return }
                imageView.image = photoImages[index]
            }
        }
    }
    
    func clearStackView() {
        imageStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
}

