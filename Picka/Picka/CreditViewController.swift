//
//  CreditViewController.swift
//  Electo
//
//  Created by Alpaca on 2017. 8. 23..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import MessageUI

class CreditViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Credit"
    }
    
    @IBAction func sendMail(sender: AnyObject) {
        let mailViewController = setMailViewController()
        
        guard MFMailComposeViewController.canSendMail() else {
            self.sendMailErrorAlert()
            return
            }
        
        self.present(mailViewController, animated: true, completion: nil)
    }
    
    func setMailViewController() -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(["Picka@gmail.com"])
        mailComposeVC.setMessageBody("Thank you for your opinions. \n - RodoPacaGiraffe -", isHTML: false)
    
        return mailComposeVC
    }
    
    func sendMailErrorAlert() {
        let title = "Mail Send Fail"
        let message = "Check Mail Setting."
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertView.addAction(okAction)
        
        self.present(alertView, animated: true, completion: nil)
    }
}

extension CreditViewController:  MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
