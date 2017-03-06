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
import SVProgressHUD

enum UserType {
    case Following, Follower, Search
}
class SearchUserViewController: BaseViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    var userName = ""
    var users = [OCTUser]()
    var userType = UserType.Search
    
    @IBOutlet weak var userTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUsers()
    }
    
    private func fetchUsers() {
        switch userType {
        case .Follower:
            title = "Followers"
            fetchFollowers()
        case .Following:
            title = "Following"
            fetchFollowing()
        default:
            break
        }
    }
    
    class func newController() -> SearchUserViewController {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchUserViewController") as! SearchUserViewController
    }
    
    private func fetchFollowing() {
        guard let token = Defaults[tokenKey].string else {
            return
        }
        let user: OCTUser = OCTUser(rawLogin: userName, server: OCTServer.dotCom())
        user.login = user.rawLogin
        let client = OCTClient.authenticatedClient(with: user, token: token)
        view.showHud()

        _ = client?.fetchFollowing(for: user, offset: UInt(users.count), perPage: 0).subscribeNext({ (user) in
            self.view.hideHud()
            if let user = user as? OCTUser {
                self.users.append(user)
                
                let data = NSKeyedArchiver.archivedData(withRootObject: self.users)
                Defaults[self.userName + "_following"] = data
                self.userTableView.reloadOnMainQueue()
            }
        }, error: { error in
            self.view.hideHud()
        })
    }
    
    private func fetchFollowers() {
        guard let token = Defaults[tokenKey].string else {
            return
        }
        let user: OCTUser = OCTUser(rawLogin: userName, server: OCTServer.dotCom())
        user.login = user.rawLogin
        let client = OCTClient.authenticatedClient(with: user, token: token)
        view.showHud()
        
        _ = client?.fetchFollowers(for: user, offset: UInt(users.count), perPage: 0).subscribeNext({ (user) in
            self.view.hideHud()
            if let user = user as? OCTUser {
                self.users.append(user)
                
                let data = NSKeyedArchiver.archivedData(withRootObject: self.users)
                Defaults[self.userName + "_follower"] = data
                self.userTableView.reloadOnMainQueue()
            }
        }, error: { error in
            self.view.hideHud()
        })
    }

    // MARK: Search user with keyword
    internal func searchUserName(withKeyword keyword: String) {
        guard let client = GithubAuthen.getGithubClientMine() else {
            return
        }
        SVProgressHUD.show()
        _ = client.fetchPopularUsers(withKeyword: keyword, location: "", language: "").subscribeNext{ users in
            SVProgressHUD.dismiss()
            
            if let users = users as? [OCTUser] {
                self.users.removeAll()
                self.users.append(contentsOf: users)
                let data = NSKeyedArchiver.archivedData(withRootObject: self.users)
                Defaults[self.userName + "_search_keyword"] = data
                self.userTableView.reloadOnMainQueue()
            }
        }
    }

    override func loadMore() {
        fetchUsers()
    }
    
}

extension SearchUserViewController: UITableViewDataSource, UITableViewDelegate {
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userView = UserViewController.newController()
        userView.userName = users[indexPath.row].login
        navigationController?.pushViewController(userView, animated: true)
    }
    
}

extension SearchUserViewController: UISearchBarDelegate {
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text else {
            return
        }
        searchUserName(withKeyword: keyword)
    }

}
