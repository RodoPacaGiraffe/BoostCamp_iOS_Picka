//
//  PhotoDataSource.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 7..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject {
    let photoStore: PhotoStore
    let removeStore: RemovedPhotoStore
    
    override init() {
        photoStore = PhotoStore()
        removeStore = RemovedPhotoStore()
        
        removeStore.delegate = photoStore
        
        super.init()
    }
}

extension PhotoDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return photoStore.classifiedPhotoAssets.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? ClassifiedPhotoCell ?? ClassifiedPhotoCell()
        
        let photoAssets = photoStore.classifiedPhotoAssets[indexPath.section]
        
        photoAssets.forEach {
            $0.fetchImage(size: CGSize(width: 50, height: 50),
                contentMode: .aspectFit, options: nil) { photoImage in
                guard let photoImage = photoImage else { return }
                cell.addPhotoImagesToStackView(photoImages: photoImage)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let assets = photoStore.classifiedPhotoAssets[indexPath.section]
        
        removeStore.addPhotoAssets(toDelete: assets)
        tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
    }
}

