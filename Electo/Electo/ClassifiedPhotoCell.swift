//
//  ImageCell.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 5..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

class ClassifiedPhotoCell: UITableViewCell {
    @IBOutlet var numberOfPhotosLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var imageStackView: UIStackView!
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet var moreImagesLabel: UILabel!
    
    var cellImages: [UIImage] = .init() {
        didSet {
            addPhotoImagesToStackView(photoImages: cellImages)
        }
    }
    
    func update(date: String, location: String?) {
        numberOfPhotosLabel.text = date
        locationLabel.text = location
    }
    
    func addPhotoImagesToStackView(photoImages: [UIImage]) {
        moreImagesLabel.isHidden = true
        for index in photoImages.indices {
            guard index < Constants.maximumImageView else {
                setLabel()
                break
            }
            imageViews[index].image = photoImages[index]
        }
        imageStackView.subviews.first?.makeRoundBorder(degree: 16.0)
        imageStackView.subviews.first?.backgroundColor = UIColor.init(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
    }
    
    func setLabel() {
        guard let lastIamgeView = imageViews.last else { return }
        lastIamgeView.image = lastIamgeView.image?.alpha(0.5)
        
        let numOfMoreImages = cellImages.count - Constants.maximumImageView
        moreImagesLabel.text = "+\(numOfMoreImages)"
        moreImagesLabel.isHidden = false
    }
    
    func clearStackView() {
        imageViews.forEach {
            $0.image = nil
        }

        moreImagesLabel.isHidden = true
        locationLabel.text = nil
    }
}

