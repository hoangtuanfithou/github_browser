//
//  UserViewController.swift
//  GithubBrowser
//
//  Created by Nguyen Hoang Tuan on 3/1/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import UIKit
import OctoKit
import SwiftyUserDefaults
import SDWebImage

class UserViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var ownerRepoTableView: UITableView!
    @IBOutlet weak var starRepoTableView: UITableView!
    
    var userName = ""
    var currentUser: OCTUser = OCTUser()
    var ownerRepos = [OCTRepository]()
    var startRepos = [OCTRepository]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if userName.isEmpty {
            checkLoginStatus()
        } else {
            getOtherUserInfo()
        }
    }
    
    private func checkLoginStatus() {
        if !GithubAuthen.isLogin() {
            performSegue(withIdentifier: "ShowLoginView", sender: nil)
        } else {
            userName = Defaults[userNameKey].stringValue
            getMyInfo()
        }
    }
    
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            view.bringSubview(toFront: ownerRepoTableView)
        case 1:
            view.bringSubview(toFront: starRepoTableView)
        default:
            break
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLoginView", let loginView = segue.destination as? LoginViewController {
            loginView.loginCallback = { (result, user) in
                if result {
                    self.dismiss(animated: true, completion: nil)
                    self.userName = Defaults[userNameKey].stringValue
                    self.getMyInfo()
                }
            }
        } else if segue.identifier == "ShowFollowingUsers", let searchUserView = segue.destination as? SearchUserViewController {
            searchUserView.userType = .Following
            searchUserView.userName = currentUser.login
        } else if segue.identifier == "ShowFollowerUsers", let searchUserView = segue.destination as? SearchUserViewController {
            searchUserView.userType = .Follower
            searchUserView.userName = currentUser.login
        } else if segue.identifier == "ShowRepoDetail", let repoDetailView = segue.destination as? RepoDetailViewController, let repo = sender as? OCTRepository {
            repoDetailView.currentRepo = repo
        }
        
    }
 
    private func displayUserInfo(user: OCTUser) {
        // display
        userNameLabel.text = user.name
        avatarImageView.sd_setImage(with: user.avatarURL)
    }
    
    // MARK: get user info
    
    private func getOtherUserInfo() {
        guard let client = GithubAuthen.getGithubClient(withUserName: userName) else {
            return
        }
        
        let user: OCTUser = OCTUser(rawLogin: userName, server: OCTServer.dotCom())
        user.login = user.rawLogin
        _ = client.fetchUserInfo(for: user).subscribeNext{ newUser in
            self.processUser(newUser)
        }
        
        _ = client.fetchPublicRepositories(for: user, offset: 0, perPage: 30).subscribeNext{ repo in
            self.processOwnerRepo(repo)
        }
        
        _ = client.fetchStarredRepositories(for: user, offset: 0, perPage: 30).subscribeNext{ repo in
            self.processStarRepo(repo)
        }
    }
    
    private func getMyInfo() {
        guard let client = GithubAuthen.getGithubClientMine() else {
            return
        }
        
        _ = client.fetchUserInfo().subscribeNext{ newUser in
            self.processUser(newUser)
        }
        
        _ = client.fetchUserRepositories().subscribeNext{ repo in
            self.processOwnerRepo(repo)
        }
        
        _ = client.fetchUserStarredRepositories().subscribeNext{ repo in
            self.processStarRepo(repo)
        }
    }
    
    func processOwnerRepo(_ repo: Any?) {
        if let repo = repo as? OCTRepository {
            ownerRepos.append(repo)
            ownerRepoTableView.reloadOnMainQueue()
        }
    }
    
    func processStarRepo(_ repo: Any?) {
        if let repo = repo as? OCTRepository {
            startRepos.append(repo)
            starRepoTableView.reloadOnMainQueue()
        }
    }
    
    func processUser(_ newUser: Any?) {
        if let user = newUser as? OCTUser {
            self.currentUser = user
            delay {
                self.displayUserInfo(user: user)
            }
        }
    }
    
}

extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == ownerRepoTableView ? ownerRepos.count : startRepos.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = tableView == ownerRepoTableView ? "OwnerTableViewCell" : "StarTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        let repo = tableView == ownerRepoTableView ? ownerRepos[indexPath.row] : startRepos[indexPath.row]
        cell.textLabel?.text = repo.name
        cell.detailTextLabel?.text = repo.repoDescription
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repo = tableView == ownerRepoTableView ? ownerRepos[indexPath.row] : startRepos[indexPath.row]
        performSegue(withIdentifier: "ShowRepoDetail", sender: repo)
    }

}
