//
//  SearchUserViewController.swift
//  GithubBrowser
//
//  Created by Nguyen Hoang Tuan on 3/2/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import UIKit
import OctoKit
import SwiftyUserDefaults

enum UserType {
    case Following, Follower, Search
}
class SearchUserViewController: UIViewController {

    var userName: String?
    var users = [OCTUser]()
    var userType = UserType.Search
    
    @IBOutlet weak var userTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = userName else {
            return
        }
        switch userType {
        case .Follower:
            fetchFollowers()
        case .Following:
            fetchFollowing()
        default:
            break
            
        }
    }
    
    private func fetchFollowing() {
        guard let token = Defaults["github_token"].string, let userName = userName else {
            return
        }
        
        let user = OCTUser(rawLogin: userName, server: OCTServer.dotCom())
        let client = OCTClient.authenticatedClient(with: user, token: token)
        _ = client?.fetchFollowing(for: user, offset: 0, perPage: 0).subscribeNext({ (user) in
            if let user = user as? OCTUser {
                self.users.append(user)
                delay {
                    self.userTableView.reloadData()
                }
            }
        }, completed: {
            delay {
                self.userTableView.reloadData()
            }
        })
    }
    
    private func fetchFollowers() {
        guard let token = Defaults["github_token"].string, let userName = userName else {
            return
        }
        
        let user = OCTUser(rawLogin: userName, server: OCTServer.dotCom())
        let client = OCTClient.authenticatedClient(with: user, token: token)
        _ = client?.fetchFollowers(for: user, offset: 0, perPage: 0).subscribeNext({ (user) in
            if let user = user as? OCTUser {
                self.users.append(user)
                delay {
                    self.userTableView.reloadData()
                }
            }
        }, completed: {
            delay {
                self.userTableView.reloadData()
            }
        })
    }

    // MARK: Search user with keyword
    private func searchUserName(withKeyword keyword: String) {
        
    }
    
}

extension SearchUserViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        return cell
    }
    
}
