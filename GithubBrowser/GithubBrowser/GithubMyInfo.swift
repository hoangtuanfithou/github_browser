//
//  GithubMyInfo.swift
//  GithubBrowser
//
//  Created by Nguyen Hoang Tuan on 3/1/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import OctoKit

class GithubMyInfo {
    
    private func getMyInfo(callBack: @escaping (Bool, OCTUser) -> Void) {
        
        let token = Defaults[tokenKey].stringValue
        let userNameString = Defaults["user_name"].stringValue
        
        if !token.isEmpty {
            let user = OCTUser(rawLogin: userNameString, server: OCTServer.dotCom())
            let client = OCTClient.authenticatedClient(with: user, token: token)
            _ = client?.fetchUserInfo().subscribeNext({ (user) in
                if let user = user as? OCTUser {
                    callBack(true, user)
                }
            })
        }
        
    }
    
    private func getMyRespo(callBack: @escaping (Bool, OCTUser) -> Void) {
        
        let token = Defaults[tokenKey].stringValue
        let userNameString = Defaults["user_name"].stringValue
        
        if !token.isEmpty {
            let user = OCTUser(rawLogin: userNameString, server: OCTServer.dotCom())
            let client = OCTClient.authenticatedClient(with: user, token: token)
            _ = client?.fetchFollowers(for: user, offset: 10, perPage: 10).subscribeNext({ (user) in
                if let user = user as? OCTUser {
                    callBack(true, user)
                }
            })
        }
        
    }
    
}
