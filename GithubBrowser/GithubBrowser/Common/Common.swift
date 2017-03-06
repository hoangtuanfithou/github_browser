//
//  Common.swift
//  GithubBrowser
//
//  Created by Nguyen Hoang Tuan on 3/2/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage
import MBProgressHUD

func delay(_ delay:Double = 0, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

extension UITableView {
    func reloadOnMainQueue() {
        delay {
            self.reloadData()
        }
    }
}

extension UIImageView {
    func sd_setImageWithIndicator(with url: URL) {
        sd_setShowActivityIndicatorView(true)
        sd_setIndicatorStyle(.gray)
        sd_setImage(with: url)
    }
}

extension UIView {
    
    func showHud() {
        MBProgressHUD.showAdded(to: self, animated: true)
    }
    
    func hideHud() {
        delay {
            MBProgressHUD.hide(for: self, animated: true)
        }
    }
    
}
