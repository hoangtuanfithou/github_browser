//
//  BaseViewController.swift
//  GithubBrowser
//
//  Created by Nguyen Hoang Tuan on 3/6/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, UIScrollViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            loadMore()
        }
    }
    
    func loadMore() {
        // need overrrid
    }
    
}
