//
//  FollowerViewController.swift
//  GithubBrowser
//
//  Created by Nguyen Hoang Tuan on 3/1/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import OctoKit

class FollowerViewController: UIViewController {

    var userName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func fetchFollowers() {
        guard let token = Defaults["github_token"].string,
            let userNameString = Defaults["user_name"].string else {
                return
        }
        
        let user = OCTUser(rawLogin: userNameString, server: OCTServer.dotCom())
        let client = OCTClient.authenticatedClient(with: user, token: token)
        _ = client?.fetchFollowers(for: user, offset: 10, perPage: 10).subscribeNext({ (user) in
            
        })
    }
    
    private func fetchFollowing() {
        guard let token = Defaults["github_token"].string,
            let userNameString = Defaults["user_name"].string else {
                return
        }
        
        let user = OCTUser(rawLogin: userNameString, server: OCTServer.dotCom())
        let client = OCTClient.authenticatedClient(with: user, token: token)
        _ = client?.fetchFollowing(for: user, offset: 10, perPage: 10).subscribeNext({ (user) in
            
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
