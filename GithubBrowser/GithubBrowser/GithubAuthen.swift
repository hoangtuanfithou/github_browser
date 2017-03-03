//
//  GithubAuthen.swift
//  GithubBrowser
//
//  Created by Nguyen Hoang Tuan on 3/1/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import SwiftyUserDefaults
import OctoKit

class GithubAuthen {
    
    class func isLogin() -> Bool{
        return !Defaults["github_token"].stringValue.isEmpty
    }
    
    // MARK: Client init
    
    class func getGithubClient(withUserName userName: String) -> OCTClient? {
        guard let token = Defaults["github_token"].string else {
            return nil
        }
        let user = OCTUser(rawLogin: userName, server: OCTServer.dotCom())
        let client = OCTClient.authenticatedClient(with: user, token: token)
        return client
    }
    
    class func getGithubClientMine() -> OCTClient? {
        guard let token = Defaults["github_token"].string,
            let userNameString = Defaults["user_name"].string else {
                return nil
        }
        let user = OCTUser(rawLogin: userNameString, server: OCTServer.dotCom())
        let client = OCTClient.authenticatedClient(with: user, token: token)
        return client
    }
    
}
