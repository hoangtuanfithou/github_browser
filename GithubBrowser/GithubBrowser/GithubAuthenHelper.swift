//
//  GithubAuthenHelper.swift
//  GithubBrowser
//
//  Created by Nguyen Hoang Tuan on 3/1/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import SwiftyUserDefaults

class GithubAuthenHelper {
    
    class func isLogin() -> Bool{
        return !Defaults["github_token"].stringValue.isEmpty

    }
    
}
