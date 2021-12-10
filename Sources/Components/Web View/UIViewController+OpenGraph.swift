//
//  UIViewController+OpenGraph.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream
import SafariServices
extension UIViewController {
    
    /// Presents the Open Graph data in a `WebViewController`.
    public func showOpenGraphData(with ogData: OGResponse?, animated: Bool = true) {
        guard let ogData = ogData else {
            return
        }
        guard var url =  ogData.url else {
            print("INVALID URL")
            return
        }

            /// Test for valid scheme & append "http" if needed
        if !(["http", "https"].contains(ogData.url?.scheme?.lowercased())) {
            
            let appendedLink = "http://" + ogData.url!.absoluteString 

            url = NSURL(string: appendedLink)! as URL
        }

        let config = SFSafariViewController.Configuration()
        let safariVC = SFSafariViewController(url: url, configuration:config)
        safariVC.preferredBarTintColor = UIColor(red: 2, green: 74, blue: 158)
        safariVC.preferredControlTintColor = UIColor.white
        safariVC.title = ogData.title
        if UIDevice.current.userInterfaceIdiom == .phone {
            safariVC.modalPresentationStyle = .popover
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            safariVC.modalPresentationStyle = .pageSheet
        }
        self.present(safariVC, animated: true, completion: nil)
        
//        let webViewController = WebViewController()
//        webViewController.url = ogData.url
//        webViewController.title = ogData.title
//        present(UINavigationController(rootViewController: webViewController), animated: animated)
    }
}
