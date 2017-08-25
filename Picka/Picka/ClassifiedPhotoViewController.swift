//
//  PhotoViewController.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 4..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

fileprivate struct Constants {
    static let customScrollImageViewFrame: CGRect = CGRect(x: 0, y: 0, width: 15, height: 30)
    static let customScrollViewCornerRadius: CGFloat = 10
    static let customScrollViewAlpha: CGFloat = 0.5
    static let scrollGestureMaximumNumberOfTouches: Int = 1
    static let scrollingLabelRoundBorderDegree: CGFloat = 5.0
    static let tableViewHeaderFont: UIFont = UIFont.systemFont(ofSize: 14)
    static let fadeAnimationDuration: TimeInterval = 0.2
    static let fadeAnimationAppearAlpha: CGFloat = 0.8
    static let fadeAnimationDisappearAlpha: CGFloat = 0.0
}

class ClassifiedPhotoViewController: UIViewController {
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet private var touchLocation: UIPanGestureRecognizer!
    
    fileprivate let customScrollView = UIView()
    fileprivate let scrollGesture = UIPanGestureRecognizer()
    fileprivate let scrollingLabel = UILabel()
    fileprivate var photoDataSource: PhotoDataSource = PhotoDataSource()
    private var moveToTempVCButtonItem: UIBarButtonItem?
    private var loadingView: LoadingView = LoadingView()
    private var statusDisplayView: StatusDisplayView = StatusDisplayView()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector (pullToRefresh), for: .valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNotificationObserver()
        setScrollDateLabel()
        setStatusDisplayView()
        setLoadingView()
        setTableView()
        setNavigationButtonItem()
        requestAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector (reloadData),
                                               name: GlobalConstants.requiredReload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (updateBadge),
                                               name: GlobalConstants.requiredUpdatingBadge, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (appearStatusDisplayView),
                                               name: GlobalConstants.appearEmptyView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (disappearStatusDisplayView),
                                               name: GlobalConstants.disappearEmptyView, object: nil)
    }
    
    private func setLoadingView() {
        loadingView = LoadingView.instanceFromNib(frame: self.view.frame)
        self.view.addSubview(loadingView)
    }
    
    private func setStatusDisplayView() {
        statusDisplayView = StatusDisplayView.instanceFromNib(status: .emptyPhotoToOrganize, frame: self.view.frame)
        self.view.addSubview(statusDisplayView)
    }
    
    private func setScrollBar() {
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            customScrollView.frame = CGRect(x: 3, y: tableView.contentOffset.y, width: 20, height: 40)
        } else {
            customScrollView.frame = CGRect(x: self.view.frame.width - 17,
                                            y: tableView.contentOffset.y, width: 20, height: 40)
        }
        
        scrollGesture.addTarget(self, action: #selector(touchToScroll))
        scrollGesture.maximumNumberOfTouches = Constants.scrollGestureMaximumNumberOfTouches
        customScrollView.layer.cornerRadius = Constants.customScrollViewCornerRadius
        customScrollView.alpha = Constants.customScrollViewAlpha
        
        let customScrollImageView: UIImageView = UIImageView()
        customScrollImageView.image = #imageLiteral(resourceName: "Slider")
        customScrollImageView.contentMode = .scaleAspectFit
        customScrollImageView.frame = Constants.customScrollImageViewFrame
        
        self.view.addSubview(customScrollView)
        customScrollView.addSubview(customScrollImageView)
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
        scrollingLabel.makeRoundBorder(degree: Constants.scrollingLabelRoundBorderDegree)
        
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
    
    private func appearLoadingView() {
        DispatchQueue.main.async { [weak self] in
            guard let classifiedPhotoVC = self else { return }
            classifiedPhotoVC.view.bringSubview(toFront: classifiedPhotoVC.loadingView)
        }
    }
    
    fileprivate func disappearLoadingView() {
        DispatchQueue.main.async { [weak self] in
            guard let classifiedPhotoVC = self else { return }
            guard classifiedPhotoVC.view.subviews.last != self?.statusDisplayView else { return }
            classifiedPhotoVC.view.bringSubview(toFront: classifiedPhotoVC.tableView)
            self?.setScrollBar()
            self?.setScrollDateLabel()
        }
    }
    
    @objc private func appearStatusDisplayView() {
        DispatchQueue.main.async { [weak self] in
            guard let classifiedPhotoVC = self else { return }
            classifiedPhotoVC.view.bringSubview(toFront: classifiedPhotoVC.statusDisplayView)
        }
    }
    
    @objc private func disappearStatusDisplayView() {
        DispatchQueue.main.async { [weak self] in
            guard let classifiedPhotoVC = self else { return }
            guard classifiedPhotoVC.view.subviews.last != self?.loadingView else { return }
            classifiedPhotoVC.view.bringSubview(toFront: classifiedPhotoVC.tableView)
            self?.setScrollBar()
            self?.setScrollDateLabel()
        }
    }
    
    private func loadUserDefaultSetting() {
        GlobalConstants.dataAllowed = UserDefaults.standard.object(forKey: "dataAllowed") as? Bool ?? true
        GlobalConstants.timeIntervalBoundary = UserDefaults.standard.object(forKey: "timeIntervalBoundary")
            as? Double ?? 180
    }
    
    private func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { [weak self] authorizationStatus in
            guard authorizationStatus == .authorized else {
                self?.permissionDeniedAlert()
                return
            }
            
            self?.appearLoadingView()
            self?.loadUserDefaultSetting()
            self?.photoDataSource.photoStore.fetchPhotoAsset()
            
            DispatchQueue.global(qos: .background).async { [weak self] in
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
        DispatchQueue.global(qos: .utility).async { [weak self] in
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
            guard let classifiedPhotoCell = tableView.cellForRow(at: indexPath)
                as? ClassifiedPhotoCell else { continue }
            
            let classifiedGroup = photoDataSource.photoStore
                .classifiedPhotoAssets[indexPath.section].photoAssetsArray[indexPath.row]
            
            guard classifiedGroup.location.isEmpty else { continue }
            
            classifiedGroup.photoAssets.first?.location?.reverseGeocode { locationString in
                classifiedGroup.location = locationString
                classifiedPhotoCell.setLocationLabelText(with: locationString)
            }
        }
    }
    
    @objc fileprivate func pullToRefresh() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.photoDataSource.photoStore.fetchPhotoAsset()
            self?.photoDataSource.photoStore.applyUnarchivedPhoto(assets: self?.photoDataSource.temporaryPhotoStore.photoAssets)
            self?.reloadData()
        }
    }
    
    @objc private func updateBadge() {
        moveToTempVCButtonItem?.updateBadge(With: photoDataSource.temporaryPhotoStore.photoAssets.count)
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
    
    private func permissionDeniedAlert() {
        let title  = NSLocalizedString("No Authorization", comment: "")
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let goSettingAction = UIAlertAction(title: NSLocalizedString("Go Settings", comment: ""),
                style: .default) { [weak self] _ in
            guard let url = URL(string:UIApplicationOpenSettingsURLString) else { return }
            UIApplication.shared.open(url)
            self?.requestAuthorization()
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel) { [weak self] _ in
            guard let windowFrame = self?.view.window?.frame else { return }
            self?.view.addSubview(StatusDisplayView.instanceFromNib(status: .noAuthorization, frame: windowFrame))
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(goSettingAction)
        
        present(alertController, animated: true, completion: nil)
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
    
    fileprivate func showDetailForSelectedPhoto(at indexPath: IndexPath) {
        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier:  "detailViewController")
            as? DetailPhotoViewController else { return }
        
        var selectedPhotoIndex = getIndexOfSelectedPhoto(from: touchLocation)
        let selectedCell = tableView.cellForRow(at: indexPath) as? ClassifiedPhotoCell ?? ClassifiedPhotoCell()
        
        if selectedCell.imageViews[selectedPhotoIndex].image == nil {
            selectedPhotoIndex = 0
        }
        
        dataSetBeforeTransition(to: detailViewController, of: indexPath, selectedPhotoIndex)
        show(detailViewController, sender: self)
    }
    
    private func dataSetBeforeTransition(to detailViewController: DetailPhotoViewController,
                                   of indexPath: IndexPath, _ selectedPhotoIndex: Int) {
        detailViewController.photoDataSource = photoDataSource
        detailViewController.selectedSectionAssets = photoDataSource.photoStore
            .classifiedPhotoAssets[indexPath.section].photoAssetsArray[indexPath.row].photoAssets
        detailViewController.identifier = "fromClassifiedPhotoVC"
        
        detailViewController.pressedIndexPath = IndexPath(row: selectedPhotoIndex, section: 0)
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
}

extension ClassifiedPhotoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let classifiedGroup = photoDataSource.photoStore
            .classifiedPhotoAssets[indexPath.section].photoAssetsArray[indexPath.row]
        
        guard let classifiedPhotoCell = cell as? ClassifiedPhotoCell else { return }
        classifiedPhotoCell.setLocationLabelText(with: classifiedGroup.location)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let classifiedPhotoCell = cell as? ClassifiedPhotoCell else { return }
        classifiedPhotoCell.setLocationLabelText(with: "")
        classifiedPhotoCell.clearStackView()
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = Constants.tableViewHeaderFont
        header.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.05)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetailForSelectedPhoto(at: indexPath)
    }
}

extension ClassifiedPhotoViewController {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        customScrollView.fadeWithAlpha(duration: Constants.fadeAnimationDuration,
                                       alpha: Constants.fadeAnimationAppearAlpha)
        fetchLocationToVisibleCells()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        customScrollView.fadeWithAlpha(duration: Constants.fadeAnimationDuration,
                                       alpha: Constants.fadeAnimationAppearAlpha)
        fetchLocationToVisibleCells()
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        customScrollView.fadeWithAlpha(duration: Constants.fadeAnimationDuration,
                                       alpha: Constants.fadeAnimationAppearAlpha)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        customScrollView.fadeWithAlpha(duration: Constants.fadeAnimationDuration,
                                       alpha: Constants.fadeAnimationAppearAlpha)
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        customScrollView.fadeWithAlpha(duration: Constants.fadeAnimationDuration,
                                       alpha: Constants.fadeAnimationAppearAlpha)
    }
}

extension ClassifiedPhotoViewController: SettingDelegate {
    func groupingChanged() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
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
        if let indexPath = tableView.indexPathForRow(at: CGPoint(x: 0, y: tableView.contentOffset.y + self.customScrollView.frame.origin.y)) {
            scrollingLabel.isHidden = false
            scrollingLabel.fadeWithAlpha(duration: Constants.fadeAnimationDuration,
                                         alpha: Constants.fadeAnimationAppearAlpha)
            scrollingLabel.text = tableView.headerView(forSection: indexPath.section)?.textLabel?.text
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
            tableView.setContentOffset(CGPoint(x: 0, y: (self.customScrollView.frame.origin.y / estimatedViewHeight) * (tableView.contentSize.height - self.view.frame.height)), animated: false)
            customScrollView.frame.origin.y = scrollGesture.location(in: self.view).y
            
        }
        
        if scrollGesture.state == .cancelled {
            scrollingLabel.isHidden = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        customScrollView.fadeWithAlpha(duration: Constants.fadeAnimationDuration,
                                       alpha: Constants.fadeAnimationAppearAlpha)
        
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
        customScrollView.fadeWithAlpha(duration: Constants.fadeAnimationDuration,
                                       alpha: Constants.fadeAnimationAppearAlpha)
        scrollingLabel.fadeWithAlpha(duration: Constants.fadeAnimationDuration,
                                     alpha: Constants.fadeAnimationDisappearAlpha)
    }
}
