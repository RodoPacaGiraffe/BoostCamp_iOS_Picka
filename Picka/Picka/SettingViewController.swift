//
//  SettingViewController.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 17..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    struct SlideToDismiss {
        static let activateBounds: CGFloat = 200.0
        static let duration: TimeInterval = 0.2
    }
}

class SettingViewController: UITableViewController {
    @IBOutlet private var slider: UISlider!
    @IBOutlet private var dataAllowedSwitch: UISwitch!
    
    private var originalNavigationPosition: CGPoint?
    private var originalPosition: CGPoint?
    var settingDelegate: SettingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSwitch()
        setSlider()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    private func setSwitch() {
        let dataAllowed: Bool = UserDefaults.standard.object(forKey: UserDefaultsKey.networkDataAllowed) as? Bool ?? true
        dataAllowedSwitch.setOn(dataAllowed, animated: false)
    }
    
    private func setSlider() {
        let timeIntervalBoundary: Double = UserDefaults.standard.object(forKey: UserDefaultsKey.timeIntervalBoundary)
            as? Double ?? Double(GroupingInterval.level2.rawValue)
        slider.setValue(Float(timeIntervalBoundary), animated: false)
    }
    
    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        tableView.isScrollEnabled = false
        
        switch sender.value {
        case Clustering.interval1:
            sender.value = GroupingInterval.level1.rawValue
        case Clustering.interval2:
            sender.value = GroupingInterval.level2.rawValue
        default:
            sender.value = GroupingInterval.level3.rawValue
        }
        
        SettingConstants.timeIntervalBoundary = Double(sender.value)
        
        UserDefaults.standard.set(SettingConstants.timeIntervalBoundary, forKey: UserDefaultsKey.timeIntervalBoundary)
        UserDefaults.standard.synchronize()
        
        tableView.isScrollEnabled = true
    }
    
    @IBAction private func networkAllowSwitch(_ sender: UISwitch) {
        switch sender.isOn {
        case true:
            let title = NSLocalizedString(LocalizationKey.useCellularData, comment: "")
            let alertController = UIAlertController(title: title, message: nil,
                                                    preferredStyle: .alert)
            
            let okAction = UIAlertAction(
                title: NSLocalizedString(LocalizationKey.ok, comment: ""),
                style: .default,
                handler: { _ in
                    SettingConstants.networkDataAllowed = true
                    
                    UserDefaults.standard.set(SettingConstants.networkDataAllowed, forKey: UserDefaultsKey.networkDataAllowed)
                    UserDefaults.standard.synchronize()
            })
            
            let cancelAction = UIAlertAction(
                title: NSLocalizedString(LocalizationKey.cancel, comment: ""),
                style: .cancel,
                handler: { _ in
                    sender.setOn(false, animated: true)
                    SettingConstants.networkDataAllowed = false
                    
                    UserDefaults.standard.set(SettingConstants.networkDataAllowed, forKey: UserDefaultsKey.networkDataAllowed)
                    UserDefaults.standard.synchronize()
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        case false:
            SettingConstants.networkDataAllowed = false
            
            UserDefaults.standard.set(SettingConstants.networkDataAllowed, forKey: UserDefaultsKey.networkDataAllowed)
            UserDefaults.standard.synchronize()
        }
    }
    
    @IBAction private func slideToDismiss(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        let originalViewFrame = self.view.frame.origin
        
        switch sender.state {
        case .began:
            originalPosition = view.center
            originalNavigationPosition = navigationController?.navigationBar.center
        case .changed:
            if translation.y > Constants.SlideToDismiss.activateBounds {
                UIView.animate(withDuration: Constants.SlideToDismiss.duration, animations: {
                    self.view.frame.origin = CGPoint(x: originalViewFrame.x,
                                                     y: translation.y + 64)
                    self.navigationController?.navigationBar.frame.origin = CGPoint(x: originalViewFrame.x,
                                                                                    y: translation.y + 20)
                })
            }
        case .ended:
            dismissWhenTouchesEnded(sender)
        default:
            break
        }
    }
    
    private func dismissWhenTouchesEnded(_ sender: UIPanGestureRecognizer) {
        var originalViewFrame = self.view.frame.origin
        var originalNavigationBarFrame = self.navigationController?.navigationBar.frame.origin
        let translation = sender.translation(in: self.view)
        
        guard translation.y > self.view.frame.height / 2 else {
            UIView.animate(withDuration: Constants.SlideToDismiss.duration, animations: { [weak self] _ in
                guard let originalPosition = self?.originalPosition else { return }
                guard let originalNavigationPosition = self?.originalNavigationPosition else { return }
                
                self?.view.center = originalPosition
                self?.navigationController?.navigationBar.center = originalNavigationPosition
            })
            
            return
        }
        
        UIView.animate(withDuration: Constants.SlideToDismiss.duration, animations: {
            originalViewFrame = CGPoint(x: originalViewFrame.x,
                                        y: self.view.frame.size.height)
            originalNavigationBarFrame = CGPoint(x: originalViewFrame.x,
                                                 y: self.view.frame.size.height)
        }, completion: { [weak self] completed in
            guard completed == true else { return }
            self?.dismiss(animated: true, completion: nil)
        })
    }

    @IBAction private func modalDismiss(_ sender: UIBarButtonItem) {
        self.settingDelegate?.timeIntervalBoundaryChanged()
        self.dismiss(animated: true, completion: nil)
    }
}

