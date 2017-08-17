//
//  PhotoViewController.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 4..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

class ClassifiedPhotoViewController: UIViewController {
    //MARK: Properties
    @IBOutlet var tableView: UITableView!
    
    var photoDataSource: PhotoDataSource = PhotoDataSource()
    var moveToTempVCButtonItem: UIBarButtonItem?
    private let loadingView = LoadingView.instanceFromNib()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector (pullToRefresh), for: .valueChanged)
        
        return refreshControl
    }()
    
    private var timer: Timer?
    
    private var time: TimeInterval = 0 {
        didSet {
            if time == Constants.loadingTime {
                stopTimer()
                disappearLoadingView()
            }
        }
    }
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        setTableView()
        appearLoadingView()
        setNavigationButtonItem()
        requestAuthorization()
        
        NotificationCenter.default.addObserver(self, selector: #selector (reloadData),
                                               name: Constants.requiredReload, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let count = photoDataSource.temporaryPhotoStore.photoAssets.count

        moveToTempVCButtonItem?.updateBadge(With: count)
        tableView.reloadData()
    }
    
    private func setTableView() {
        tableView.dataSource = photoDataSource
        tableView.addSubview(refreshControl)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func appearLoadingView() {
        timer = Timer.scheduledTimer(withTimeInterval: Constants.loadingTime, repeats: true) {
            [weak self] (timer: Timer) in
            
            self?.time += timer.timeInterval
        }
        
        self.view.addSubview(loadingView)
    }
    
    private func disappearLoadingView() {
        self.loadingView.stopIndicatorAnimating()
        self.loadingView.removeFromSuperview()
    }
    
    @objc private func pullToRefresh() {
        DispatchQueue.global().async { [weak self] in
            self?.photoDataSource.photoStore.fetchPhotoAsset()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    private func deniedAlert() {
        let alertController = UIAlertController(title: "", message: "No Authorization", preferredStyle: .alert)
        let goSettingAction = UIAlertAction(title: "Go Settings", style: .default) { (action) in
            guard let url = URL(string:UIApplicationOpenSettingsURLString) else { return }
            UIApplication.shared.open(url)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(goSettingAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization {
            [weak self] (authorizationStatus) -> Void in
            guard authorizationStatus == .authorized else {
                self?.deniedAlert()
                return
            }
            self?.photoDataSource.photoStore.fetchPhotoAsset()
            
            guard let path = Constants.archiveURL?.path else { return }

            self?.fetchArchivedTemporaryPhotoStore(from: path)
        }
    }
    
    private func fetchArchivedTemporaryPhotoStore(from path: String) {
        DispatchQueue.global().async {
            [weak self] in
            guard let archivedtemporaryPhotoStore = NSKeyedUnarchiver.unarchiveObject(withFile: path)
                as? TemporaryPhotoStore else {
                    self?.reloadData()
                    return
            }
            print("here")
            self?.photoDataSource.temporaryPhotoStore = archivedtemporaryPhotoStore
            self?.photoDataSource.temporaryPhotoStore.fetchPhotoAsset()
            
            let unarchivedPhotoAssets = self?.photoDataSource.temporaryPhotoStore.photoAssets
            
            let removedAssetsFromLibrary = self?.photoDataSource.photoStore.applyUnarchivedPhoto(assets: unarchivedPhotoAssets)
            
            if let photoAssets = removedAssetsFromLibrary {
                self?.photoDataSource.temporaryPhotoStore.remove(
                    photoAssets: photoAssets, isPerformDelegate: false)
            }
            
            self?.reloadData()
        }
    }
    
    private func setNavigationButtonItem() {
        moveToTempVCButtonItem = UIBarButtonItem.getUIBarbuttonItemincludedBadge(With: 0)
        
        moveToTempVCButtonItem?.addButtonTarget(target: self,
                                                action: #selector (moveToTemporaryViewController),
                                                for: .touchUpInside)
        
        self.navigationItem.setRightBarButton(moveToTempVCButtonItem, animated: true)
    }
    
    @objc private func moveToTemporaryViewController() {
        performSegue(withIdentifier: "ModalRemovedPhotoVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ModalRemovedPhotoVC" else { return }
        guard let navigationController = segue.destination as? UINavigationController,
            let temporaryPhotoViewController = navigationController.topViewController
                as? TemporaryPhotoViewController else { return }
        
        temporaryPhotoViewController.photoDataSource = photoDataSource
    }
    
    @objc private func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            
            guard let count = self?.photoDataSource.temporaryPhotoStore.photoAssets.count else { return }
            
            self?.moveToTempVCButtonItem?.updateBadge(With: count)
        }
    }

    @IBAction func networkAllowSwitch(_ sender: UISwitch) {
       print(sender.state)
        if sender.isOn {
            let alertController = UIAlertController(title: "", message: "It will use network data", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                Constants.dataAllowed = true
            })
            let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: { (action) in
                Constants.dataAllowed = false
            })
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        } else {
            Constants.dataAllowed = false
        }
    }
}

extension ClassifiedPhotoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let photoCell = cell as? ClassifiedPhotoCell else {
            print("cell is not a photoCell")
            return
        }

        photoCell.clearStackView()
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
      
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.systemFont(ofSize: 14)
        header.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier:  "detailViewController") as? DetailPhotoViewController else { return }
      
        detailViewController.photoDataSource = photoDataSource
        detailViewController.selectedSectionAssets = photoDataSource.photoStore.classifiedPhotoAssets[indexPath.section].photoAssetsArray[indexPath.row].photoAssets
       
        detailViewController.identifier = "fromClassifiedView"
        let selectedCell = tableView.cellForRow(at: indexPath) as? ClassifiedPhotoCell ?? ClassifiedPhotoCell.init()
        detailViewController.thumbnailImages = selectedCell.cellImages
        detailViewController.pressedIndexPath = IndexPath(row: 0, section: 0)
        
        show(detailViewController, sender: self)
    }
}


