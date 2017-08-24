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
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet private var touchLocation: UIPanGestureRecognizer!
    
    fileprivate let customScrollView = UIView()
    fileprivate let scrollGesture = UIPanGestureRecognizer()
    fileprivate let scrollingLabel = UILabel()
    fileprivate var photoDataSource: PhotoDataSource = PhotoDataSource()
    private var moveToTempVCButtonItem: UIBarButtonItem?
    private var loadingView: LoadingView = LoadingView()
    private var emptyView: EmptyView = EmptyView()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector (pullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNotificationObserver()
        setScrollDateLabel()
        setEmptyView()
        setLoadingView()
        setTableView()
        setNavigationButtonItem()
        requestAuthorization()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector (reloadData),
                                               name: Constants.requiredReload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (updateBadge),
                                               name: Constants.requiredUpdatingBadge, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (appearEmptyView),
                                               name: Constants.appearEmptyView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (disappearEmptyView),
                                               name: Constants.disappearEmptyView, object: nil)
    }
    
    private func setLoadingView() {
        loadingView = LoadingView.instanceFromNib(frame: self.view.frame)
        self.view.addSubview(loadingView)
    }
    
    private func setEmptyView() {
        emptyView = EmptyView.instanceFromNib(situation: .noPhoto, frame: self.view.frame)
        self.view.addSubview(emptyView)
    }
    
    @objc private func appearEmptyView() {
        DispatchQueue.main.async { [weak self] in
            guard let classifiedPhotoVC = self else { return }
            classifiedPhotoVC.view.bringSubview(toFront: classifiedPhotoVC.emptyView)
        }
    }
    
    @objc private func disappearEmptyView() {
        DispatchQueue.main.async { [weak self] in
            guard let classifiedPhotoVC = self else { return }
            guard classifiedPhotoVC.view.subviews.last != self?.loadingView else { return }
            classifiedPhotoVC.view.bringSubview(toFront: classifiedPhotoVC.tableView)
            self?.setScrollBar()
            self?.setScrollDateLabel()
        }
    }
    
    private func appearLoadingView() {
        DispatchQueue.main.async { [weak self] in
            guard let classifiedPhotoVC = self else { return }
            classifiedPhotoVC.view.bringSubview(toFront: classifiedPhotoVC.loadingView)
        }
    }
    
    fileprivate func disappearLoadingView() {
        DispatchQueue.main.async { [weak self] in
            guard let classifiedPhotoVC = self else { return }
            guard classifiedPhotoVC.view.subviews.last != self?.emptyView else { return }
            classifiedPhotoVC.view.bringSubview(toFront: classifiedPhotoVC.tableView)
            self?.setScrollBar()
            self?.setScrollDateLabel()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    private func loadUserDefaultSetting() {
        Constants.dataAllowed = UserDefaults.standard.object(forKey: "dataAllowed") as? Bool ?? true
        Constants.timeIntervalBoundary = UserDefaults.standard.object(forKey: "timeIntervalBoundary")
            as? Double ?? 180
    }
    
    private func setScrollBar() {
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            customScrollView.frame = CGRect(x: 3, y: tableView.contentOffset.y, width: 20, height: 40)
        } else {
            customScrollView.frame = CGRect(x: self.view.frame.width - 17,
                                            y: tableView.contentOffset.y, width: 20, height: 40)
        }
        
        scrollGesture.addTarget(self, action: #selector(touchToScroll))
        scrollGesture.maximumNumberOfTouches = 1
        customScrollView.layer.cornerRadius = 10
        customScrollView.alpha = 0.5
        
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "Slider.png")
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 15, height: 30)
        
        
        self.view.addSubview(customScrollView)
        customScrollView.addSubview(imageView)
        customScrollView.addGestureRecognizer(scrollGesture)
    }
    
    private func setScrollDateLabel() {
        scrollingLabel.frame = CGRect(x: self.view.frame.width / 4,
                                      y: self.view.center.y - 100,
                                      width: self.view.frame.width / 2,
                                      height: 50)
        scrollingLabel.isHidden = true
        scrollingLabel.textAlignment = .center
        scrollingLabel.adjustsFontSizeToFitWidth = true
        scrollingLabel.backgroundColor = UIColor.lightGray
        scrollingLabel.makeRoundBorder(degree: 5)
        
        self.view.addSubview(scrollingLabel)
    }
    
    private func setTableView() {
        tableView.dataSource = photoDataSource
        tableView.addSubview(refreshControl)
    }
    
    private func setNavigationButtonItem() {
        moveToTempVCButtonItem = UIBarButtonItem.getUIBarbuttonItemincludedBadge(With: 0)
    
        moveToTempVCButtonItem?.addButtonTarget(target: self,
                                                action: #selector (moveToTemporaryViewController),
                                                for: .touchUpInside)
        
        self.navigationItem.setRightBarButton(moveToTempVCButtonItem, animated: true)
    }
    
    @objc fileprivate func pullToRefresh() {
        DispatchQueue.global().async { [weak self] in
            self?.photoDataSource.photoStore.fetchPhotoAsset()
            self?.photoDataSource.photoStore.applyUnarchivedPhoto(assets: self?.photoDataSource.temporaryPhotoStore.photoAssets)
            self?.reloadData()
        }
    }
    
    @objc private func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            
            guard let count = self?.photoDataSource.temporaryPhotoStore.photoAssets.count else { return }
            
            self?.moveToTempVCButtonItem?.updateBadge(With: count)
            self?.refreshControl.endRefreshing()
            self?.fetchLocationToVisibleCells()
        }
    }
    
    private func deniedAlert() {
        let title  = NSLocalizedString("No Authorization", comment: "")
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let goSettingAction = UIAlertAction(title: NSLocalizedString("Go Settings", comment: ""),
                style: .default) { [weak self] _ in
            guard let url = URL(string:UIApplicationOpenSettingsURLString) else { return }
            UIApplication.shared.open(url)
            self?.requestAuthorization()
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                style: .destructive) { [weak self] _ in
            guard let windowFrame = self?.view.window?.frame else { return }
            self?.view.addSubview(EmptyView.instanceFromNib(situation: .noAuthorization, frame: windowFrame))
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(goSettingAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { [weak self] authorizationStatus in
            guard authorizationStatus == .authorized else {
                self?.deniedAlert()
                return
            }
            
            self?.appearLoadingView()
            self?.loadUserDefaultSetting()
            self?.photoDataSource.photoStore.fetchPhotoAsset()
            
            DispatchQueue.global().async { [weak self] in
                guard let photoAssets = self?.photoDataSource.photoStore.photoAssets else { return }
                CachingImageManager.shared.startCachingImages(for: photoAssets,
                                                              targetSize: Constants.fetchImageSize,
                                                              contentMode: .aspectFill, options: nil)
            }
            
            guard let path = Constants.archiveURL?.path else { return }
            self?.fetchArchivedTemporaryPhotoStore(from: path)
        }
    }
    
    private func fetchArchivedTemporaryPhotoStore(from path: String) {
        DispatchQueue.global().async { [weak self] in
            guard let archivedtemporaryPhotoStore = NSKeyedUnarchiver.unarchiveObject(withFile: path)
                as? TemporaryPhotoStore else {
                    self?.disappearLoadingView()
                    self?.reloadData()
                    return
            }
            
            self?.photoDataSource.temporaryPhotoStore = archivedtemporaryPhotoStore
            self?.photoDataSource.temporaryPhotoStore.fetchPhotoAsset()
            
            let unarchivedPhotoAssets = self?.photoDataSource.temporaryPhotoStore.photoAssets
            let removedAssetsFromLibrary = self?.photoDataSource.photoStore.applyUnarchivedPhoto(assets: unarchivedPhotoAssets)
            
            if let photoAssets = removedAssetsFromLibrary {
                self?.photoDataSource.temporaryPhotoStore.remove(photoAssets: photoAssets, isPerformDelegate: false)
            }
            
            self?.disappearLoadingView()
            self?.reloadData()
        }
    }
    
    fileprivate func fetchLocationToVisibleCells() {
        guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
        
        for indexPath in indexPaths {
            guard let photoCell = tableView.cellForRow(at: indexPath)
                as? ClassifiedPhotoCell else { continue }
            
            let classifiedGroup = photoDataSource.photoStore
                .classifiedPhotoAssets[indexPath.section].photoAssetsArray[indexPath.row]
            
            guard classifiedGroup.location.isEmpty else { continue }
            
            classifiedGroup.photoAssets.first?.location?.reverseGeocode { locationString in
                photoCell.locationLabel.text = locationString
                classifiedGroup.location = locationString
            }
        }
    }
    
    @objc private func moveToTemporaryViewController() {
        performSegue(withIdentifier: "ModalRemovedPhotoVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "ModalRemovedPhotoVC":
            guard let navigationController = segue.destination as? UINavigationController,
                let temporaryPhotoViewController = navigationController.topViewController
                    as? TemporaryPhotoViewController else { return }
            temporaryPhotoViewController.photoDataSource = photoDataSource
        case "PressedSetting":
            guard let navigationController = segue.destination as? UINavigationController,
                let settingViewController = navigationController.topViewController
                    as? SettingViewController else { return }
            settingViewController.settingDelegate = self
        default:
            break
        }
    }
    
    @objc private func updateBadge() {
        moveToTempVCButtonItem?.updateBadge(With: photoDataSource.temporaryPhotoStore.photoAssets.count)
    }
    
    private func getIndexOfSelectedPhoto(from sender: UIPanGestureRecognizer) -> Int {
        var location: CGFloat = 0
        let bound = self.view.frame.width
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            location = self.view.frame.width - sender.location(in: self.view).x
        } else {
            location = sender.location(in: self.view).x
        }
        
        switch location {
        case 0..<bound / 4:
            return PhotoIndex.first.rawValue
        case (bound / 4)..<(bound / 2):
            return PhotoIndex.second.rawValue
        case (bound / 2)..<(3 * bound / 4):
            return PhotoIndex.third.rawValue
        case (3 * bound / 4)..<(bound):
            return PhotoIndex.fourth.rawValue
        default:
            return PhotoIndex.first.rawValue
        }
    }
    
    fileprivate func showSelectedPhoto(at indexPath: IndexPath) {
        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier:  "detailViewController")
            as? DetailPhotoViewController else { return }
        
        var selectedPhotoIndex = getIndexOfSelectedPhoto(from: touchLocation)
        let selectedCell = tableView.cellForRow(at: indexPath) as? ClassifiedPhotoCell ?? ClassifiedPhotoCell()
        
        if selectedCell.imageViews[selectedPhotoIndex].image == nil {
            selectedPhotoIndex = 0
        }
        
        dataSetOfTransfer(to: detailViewController, selectedCell: selectedCell, of: indexPath, selectedPhotoIndex)
        show(detailViewController, sender: self)
    }
    
    private func dataSetOfTransfer(to detailViewController: DetailPhotoViewController, selectedCell: ClassifiedPhotoCell,
                           of indexPath: IndexPath, _ selectedPhotoIndex: Int) {
        detailViewController.photoDataSource = photoDataSource
        detailViewController.selectedSectionAssets = photoDataSource.photoStore
            .classifiedPhotoAssets[indexPath.section].photoAssetsArray[indexPath.row].photoAssets
        detailViewController.identifier = "fromClassifiedPhotoVC"

        detailViewController.pressedIndexPath = IndexPath(row: selectedPhotoIndex, section: 0)
    }
}

extension ClassifiedPhotoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let classifiedGroup = photoDataSource.photoStore
            .classifiedPhotoAssets[indexPath.section].photoAssetsArray[indexPath.row]
        
        guard let photoCell = cell as? ClassifiedPhotoCell else { return }
        photoCell.locationLabel.text = classifiedGroup.location
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let photoCell = cell as? ClassifiedPhotoCell else { return }
        photoCell.locationLabel.text = ""
        photoCell.clearStackView()
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.systemFont(ofSize: 14)
        header.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.05)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showSelectedPhoto(at: indexPath)
    }
}

extension ClassifiedPhotoViewController {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        customScrollView.fadeWithAlpha(of: customScrollView, duration: 0.2, alpha: 0.5)
        fetchLocationToVisibleCells()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        customScrollView.fadeWithAlpha(of: customScrollView, duration: 0.2, alpha: 0.5)
        fetchLocationToVisibleCells()
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        customScrollView.fadeWithAlpha(of: customScrollView, duration: 0.2, alpha: 0.5)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        customScrollView.fadeWithAlpha(of: customScrollView, duration: 0.5, alpha: 0.8)
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        customScrollView.fadeWithAlpha(of: customScrollView, duration: 0.5, alpha: 0.8)
    }
}

extension ClassifiedPhotoViewController: SettingDelegate {
    func groupingChanged() {
        DispatchQueue.global().async { [weak self] in
            self?.photoDataSource.photoStore.fetchPhotoAsset()
            self?.photoDataSource.photoStore.applyUnarchivedPhoto(assets: self?.photoDataSource.temporaryPhotoStore.photoAssets)
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.disappearLoadingView()
                self?.fetchLocationToVisibleCells()
            }
        }
    }
}

extension ClassifiedPhotoViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ClassifiedPhotoViewController {
    func touchToScroll() {
        guard scrollGesture.state != .ended else {
            fadeOutLabelAndIndicator()
            return
        }
    
        guard tableView.contentSize.height > self.view.frame.height else { return }
        guard let naviBarHeight = self.navigationController?.navigationBar.frame.size.height else { return }
        if let indexPath = tableView.indexPathForRow(at: CGPoint(x: 0, y: tableView.contentOffset.y + self.customScrollView.frame.origin.y))  {
            scrollingLabel.isHidden = false
            scrollingLabel.fadeWithAlpha(of: scrollingLabel, duration: 0.3, alpha: 0.8)
            scrollingLabel.text = tableView.headerView(forSection: indexPath.section)?.textLabel?.text
            scrollingLabel.fadeWithAlpha(of: scrollingLabel, duration: 0.5, alpha: 0.8)
        }
        
        if scrollGesture.location(in: self.view).y + naviBarHeight > self.view.frame.height {
            scrollingLabel.text = tableView.headerView(forSection: tableView.numberOfSections - 1)?.textLabel?.text
            tableView.contentOffset.y = tableView.contentSize.height - self.view.frame.height
            fadeOutLabelAndIndicator()
        } else if scrollGesture.location(in: self.view).y < 0 {
            scrollingLabel.text = tableView.headerView(forSection: 0)?.textLabel?.text
            tableView.contentOffset.y = 0
            fadeOutLabelAndIndicator()
        } else {

            let estimatedViewHeight = self.view.frame.height - customScrollView.frame.size.height
            tableView.setContentOffset(CGPoint.init(x: 0, y: (self.customScrollView.frame.origin.y / estimatedViewHeight) * (tableView.contentSize.height - self.view.frame.height)), animated: false)
            customScrollView.frame.origin.y = scrollGesture.location(in: self.view).y
            
        }
        
        if scrollGesture.state == .cancelled {
            scrollingLabel.isHidden = true
            print("cancelled")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        customScrollView.fadeWithAlpha(of: customScrollView, duration: 0.2, alpha: 0.8)
        
        guard scrollView.contentOffset.y > 0 else {
            customScrollView.frame.origin.y = tableView.contentOffset.y
            return
        }
        
        // 전체 tableview 컨텐츠 사이즈에서 contentOffset 비율계산
        // -> (scrollView.contentOffset.y / scrollView.contentSize.hieght
        // 위 식을 self.view 의 높이만큼을 곱하여 화면 높이에 맞게 정규화.

        let estimatedViewHeight = self.view.frame.height - customScrollView.frame.size.height
        if scrollView.contentSize.height > self.view.frame.height {
            customScrollView.frame.origin.y = (scrollView.contentOffset.y / (scrollView.contentSize.height - self.view.frame.height)) * estimatedViewHeight
        } else {
            customScrollView.frame.origin.y = (scrollView.contentOffset.y / (self.view.frame.height - scrollView.contentSize.height)) * estimatedViewHeight
        }
    }
    
    func fadeOutLabelAndIndicator() {
        customScrollView.fadeWithAlpha(of: customScrollView, duration: 0.2, alpha: 0.5)
        scrollingLabel.fadeWithAlpha(of: scrollingLabel, duration: 0.5, alpha: 0)
    }
}
