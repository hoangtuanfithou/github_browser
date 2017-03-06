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
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!

    @IBOutlet weak var ownerRepoTableView: UITableView!
    @IBOutlet weak var starRepoTableView: UITableView!
    
    var userName = ""
    var currentUser: OCTUser = OCTUser()
    var ownerRepos = [OCTRepository]()
    var startRepos = [OCTRepository]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = userName
        if userName.isEmpty {
            checkLoginStatus()
        } else {
            getOtherUserInfo()
        }
    }
    
    class func newController() -> UserViewController {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
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
        case 0: // Owned
            view.bringSubview(toFront: ownerRepoTableView)
        case 1: // Starred
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
        userNameLabel.text = user.name
        avatarImageView.sd_setImageWithIndicator(with: user.avatarURL)
        followersButton.setTitle("Followers: \(user.followers)", for: .normal)
        followingButton.setTitle("Following: \(user.following)", for: .normal)
    }
    
    // MARK: get user info
    private func getOtherUserInfo() {
        guard let client = GithubAuthen.getGithubClient(withUserName: userName) else {
            return
        }
        
        let user: OCTUser = OCTUser(rawLogin: userName, server: OCTServer.dotCom())
        user.login = user.rawLogin
        _ = client.fetchUserInfo(for: user).subscribeNext({ [weak self] newUser in
            self?.processUser(newUser)
            }, error: { [weak self] error in
               self?.processUserError(error)
        })
        
        _ = client.fetchPublicRepositories(for: user, offset: 0, perPage: 30).subscribeNext({ [weak self] repo in
            self?.processOwnerRepo(repo)
            }, error: { [weak self] error in
                self?.processOwnerRepoError(error)
        })
        
        _ = client.fetchStarredRepositories(for: user, offset: 0, perPage: 30).subscribeNext({ [weak self] repo in
            self?.processStarRepo(repo)
            }, error: { [weak self] error in
                self?.processStarRepoError(error)
        })
    }
    
    private func getMyInfo() {
        guard let client = GithubAuthen.getGithubClientMine() else {
            return
        }
        
        _ = client.fetchUserInfo().subscribeNext({ [weak self] newUser in
            self?.processUser(newUser)
            }, error: { [weak self] error in
                self?.processUserError(error)
        })
        
        _ = client.fetchUserRepositories().subscribeNext({ [weak self] repo in
            self?.processOwnerRepo(repo)
            }, error: { [weak self] error in
                self?.processOwnerRepoError(error)
        })
        
        _ = client.fetchUserStarredRepositories().subscribeNext({ [weak self] repo in
            self?.processStarRepo(repo)
            }, error: { [weak self] error in
                self?.processStarRepoError(error)
        })
    }
    
    // MARK: Process in case Error
    private func processUserError(_ error: Error?) {
        if error?._code == OctokitNoInternetErrorCode, let data = Defaults[userName].data,
            let cachedUser = NSKeyedUnarchiver.unarchiveObject(with: data) {
            processUser(cachedUser)
        }
    }
    
    private func processOwnerRepoError(_ error: Error?) {
        if error?._code == OctokitNoInternetErrorCode,
            let data = Defaults[userName + "_ownerRepos"].data,
            let ownerReposCached = NSKeyedUnarchiver.unarchiveObject(with: data),
            let repos = ownerReposCached as? [OCTRepository] {
            ownerRepos.append(contentsOf: repos)
            ownerRepoTableView.reloadOnMainQueue()
        }
    }
    
    private func processStarRepoError(_ error: Error?) {
        if error?._code == OctokitNoInternetErrorCode,
            let data = Defaults[userName + "_starRepos"].data,
            let ownerReposCached = NSKeyedUnarchiver.unarchiveObject(with: data),
            let repos = ownerReposCached as? [OCTRepository] {
            startRepos.append(contentsOf: repos)
            starRepoTableView.reloadOnMainQueue()
        }
    }


    // MARK: Process in case Success
    private func processUser(_ newUser: Any?) {
        if let user = newUser as? OCTUser {
            currentUser = user
            let data = NSKeyedArchiver.archivedData(withRootObject: currentUser)
            Defaults[userName] = data
            delay {
                self.displayUserInfo(user: user)
            }
        }
    }
    
    private func processOwnerRepo(_ repo: Any?) {
        if let repo = repo as? OCTRepository {
            ownerRepos.append(repo)
            let data = NSKeyedArchiver.archivedData(withRootObject: ownerRepos)
            Defaults[userName + "_ownerRepos"] = data
            ownerRepoTableView.reloadOnMainQueue()
        }
    }
    
    private func processStarRepo(_ repo: Any?) {
        if let repo = repo as? OCTRepository {
            startRepos.append(repo)
            let data = NSKeyedArchiver.archivedData(withRootObject: startRepos)
            Defaults[userName + "_starRepos"] = data
            starRepoTableView.reloadOnMainQueue()
        }
    }
    
}

extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    
    private func getArrayRepo(forTableView tableView: UITableView) -> [OCTRepository] {
        return tableView == ownerRepoTableView ? ownerRepos : startRepos
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getArrayRepo(forTableView: tableView).count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepoTableViewCell", for: indexPath)
        
        let repo = getArrayRepo(forTableView: tableView)[indexPath.row]
        cell.textLabel?.text = repo.name
        cell.detailTextLabel?.text = repo.repoDescription
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repo = getArrayRepo(forTableView: tableView)[indexPath.row]
        performSegue(withIdentifier: "ShowRepoDetail", sender: repo)
    }

}
