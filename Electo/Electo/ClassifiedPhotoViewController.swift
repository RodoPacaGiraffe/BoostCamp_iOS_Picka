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
    
    @IBOutlet var touchLocation: UIPanGestureRecognizer!
    var photoDataSource: PhotoDataSource = PhotoDataSource()
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
        requestAuthorization()
        
        NotificationCenter.default.addObserver(self, selector: #selector (reloadData),
                                               name: Constants.requiredReload, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        
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
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
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
    
    private func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization {
            [weak self] (authorizationStatus) -> Void in
            guard authorizationStatus == .authorized else { return }
            
            self?.photoDataSource.photoStore.fetchPhotoAsset()
            
            guard let path = Constants.archiveURL?.path else {
                self?.reloadData()
                return
            }

            self?.fetchArchivedTemporaryPhotoStore(from: path)
        }
    }
    
    private func fetchArchivedTemporaryPhotoStore(from path: String) {
        DispatchQueue.global().async {
            [weak self] in
            guard let archivedtemporaryPhotoStore = NSKeyedUnarchiver.unarchiveObject(withFile: path)
                as? TemporaryPhotoStore else { return }
            
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
            print("on")
            present(alertController, animated: true, completion: nil)
        } else {
            print("off")
            Constants.dataAllowed = false
        }
    }
    
    func getLocationOfSelectedPhoto(sender: UIPanGestureRecognizer) -> Int {
        let location = sender.location(in: self.view)
        let bound = self.view.frame.width
    
        switch location.x {
        case 0..<bound/4:
            return 0
        case (bound / 4)..<(bound / 2):
            return 1
        case (bound / 2)..<(3 * bound / 4):
            return 2
        case (3 * bound / 4)..<(bound):
            return 3
        default:
            return 0
        }
    }
    
    func getSelectedPhoto(indexPath: IndexPath) {
       
        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier:  "detailViewController") as? DetailPhotoViewController else { return }
        let selectedPhotoIndex = getLocationOfSelectedPhoto(sender: touchLocation)
        let selectedCell = tableView.cellForRow(at: indexPath) as? ClassifiedPhotoCell ?? ClassifiedPhotoCell.init()
        guard selectedCell.imageViews[selectedPhotoIndex].image != nil else { return }

        detailViewController.selectedIndexPath = indexPath
        detailViewController.photoDataSource = photoDataSource
        detailViewController.identifier = "fromClassifiedView"
        detailViewController.thumbnailImages = selectedCell.cellImages
        detailViewController.pressedIndexPath = IndexPath(row: selectedPhotoIndex, section: 0)
        show(detailViewController, sender: self)
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
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        getSelectedPhoto(indexPath: indexPath)
    }
}


