//
//  CreditViewController.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 23..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import MessageUI

fileprivate struct Constants {
    struct MailComponent {
        static let officialEmail: String = "pickahelp@gmail.com"
        static let message: String = "Thank you for your opinions. \n - RodoPacaGiraffe -"
    }
    
    struct MailErrorAlert {
        static let title = "Mail Send Fail"
        static let message = "Check Mail Setting."
    }
    
    static let navigationTitle = "Credit"
}

class CreditViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = Constants.navigationTitle
    }
    
    @IBAction private func sendMail(sender: AnyObject) {
        let mailViewController = setMailViewController()
        
        guard MFMailComposeViewController.canSendMail() else {
            self.sendMailErrorAlert()
            return
        }
        
        self.present(mailViewController, animated: true, completion: nil)
    }
    
    private func setMailViewController() -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients([Constants.MailComponent.officialEmail])
        mailComposeVC.setMessageBody(Constants.MailComponent.message, isHTML: false)
    
        return mailComposeVC
    }
    
    private func sendMailErrorAlert() {
        let alertView = UIAlertController(title: Constants.MailErrorAlert.title,
                                          message: Constants.MailErrorAlert.message,
                                          preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertView.addAction(okAction)
        
        self.present(alertView, animated: true, completion: nil)
    }
}

extension CreditViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
