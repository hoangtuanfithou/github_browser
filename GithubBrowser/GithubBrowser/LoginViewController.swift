//
//  ViewController.swift
//  GithubBrowser
//
//  Created by Nguyen Hoang Tuan on 2/27/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import UIKit
import OctoKit
import SwiftyUserDefaults
import AlamofireObjectMapper
import Alamofire

class LoginViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var loginCallback: ((Bool, OCTUser?) -> Void)?
    
    @IBAction func loginAction(_ sender: Any) {
        guard let userNameString = userName.text, let passwordString = password.text else {
            return
        }
        
        let authenRequest = AuthorizationsRequest()
        authenRequest.scopes = ["public_repo"]
        authenRequest.note = "admin"
        authenRequest.clientId = "e6d814ebc8b94840d603"
        authenRequest.clientSecret = "c672d9a9b3c4ace061251f11bd6596bc166add6b"
        
        let credentialData = "\(userNameString):\(passwordString)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        
        Alamofire.request("https://api.github.com/authorizations", method: .post, parameters: authenRequest.toJSON(), encoding: JSONEncoding.default, headers: headers).responseObject { (response: DataResponse<AuthorizationsResponse>) in

            if response.result.isSuccess && response.response?.statusCode == 201,
                let authenResponse = response.result.value {
                Defaults["github_token"] = authenResponse.token
                Defaults["user_name"] = userNameString
                self.loginCallback?(true, nil)
            }
        }
        
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
