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
        
        if photoImages.count <= 4 {
            for index in photoImages.indices {
                guard let subImageView = imageStackView.arrangedSubviews[index] as? UIImageView else { break }
                subImageView.image = photoImages[index]
            }
        } else {
            for index in 0..<4 {
                guard let subImageView = imageStackView.arrangedSubviews[index] as? UIImageView else { break }
                subImageView.image = photoImages[index]
            }
            setLabel()
        }
    }
    
    func setLabel() {
        guard let lastSubImageView = imageStackView.arrangedSubviews.last as? UIImageView else { return }
        lastSubImageView.image = lastSubImageView.image?.alpha(0.5)
        let moreImagesLabel: UILabel = .init()
        lastSubImageView.addSubview(moreImagesLabel)
        
        let numberOfMoreImages = cellImages.count - 4
        moreImagesLabel.numberOfLines = 2
        let moreAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 25)]
        let moreImagesText = NSMutableAttributedString(string: "+\(numberOfMoreImages)\n장의 사진", attributes: moreAttributes)
        
        if numberOfMoreImages >= 10 {
            moreImagesText.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 15)],
                                         range: NSRange(location: 3, length: 6))
        } else {
            moreImagesText.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 15)],
                                         range: NSRange(location: 3, length: 5))
        }
        moreImagesLabel.attributedText = moreImagesText
        moreImagesLabel.textAlignment = .center
        moreImagesLabel.textColor = UIColor.black

        moreImagesLabel.translatesAutoresizingMaskIntoConstraints = false
        moreImagesLabel.centerXAnchor.constraint(equalTo: lastSubImageView.centerXAnchor).isActive = true
        moreImagesLabel.centerYAnchor.constraint(equalTo: lastSubImageView.centerYAnchor).isActive = true
    }
    
    func clearStackView() {
        imageStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
}

