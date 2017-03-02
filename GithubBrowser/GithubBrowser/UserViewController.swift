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
    
    var currentUser: OCTUser = OCTUser()
    var ownerRepos = [OCTRepository]()
    var startRepos = [OCTRepository]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !GithubAuthen.isLogin() {
            performSegue(withIdentifier: "ShowLoginView", sender: nil)
        } else {
            getUserInfo()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.view.bringSubview(toFront: ownerRepoTableView)
        case 1:
            self.view.bringSubview(toFront: starRepoTableView)
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
                    self.getUserInfo()
                }
            }
        } else if segue.identifier == "ShowFollowingUsers", let searchUserView = segue.destination as? SearchUserViewController {
            searchUserView.userType = .Following
            searchUserView.userName = currentUser.login
        } else if segue.identifier == "ShowFollowerUsers", let searchUserView = segue.destination as? SearchUserViewController {
            searchUserView.userType = .Follower
            searchUserView.userName = currentUser.login
        } else if segue.identifier == "ShowRepoDetail", let repoDetailView = segue.destination as? RepoDetailViewController {
            
        }
        
    }
 
    private func displayUserInfo(user: OCTUser) {
        // display
        userNameLabel.text = user.name
        avatarImageView.sd_setImage(with: user.avatarURL)
    }
    
    // MARK: get user info
    private func getUserInfo() {
        guard let client = GithubAuthen.getGithubClientMine() else {
            return
        }
        
        // get user info
        _ = client.fetchUserInfo().subscribeNext({ (newUser) in
            if let user = newUser as? OCTUser {
                self.currentUser = user
                delay {
                    self.displayUserInfo(user: user)
                }
            }
        })
        
        // fetchUserRepositories
        _ = client.fetchUserRepositories().subscribeNext({ (repo) in
            if let repo = repo as? OCTRepository {
                debugPrint(repo)
                self.ownerRepos.append(repo)
                delay {
                    self.ownerRepoTableView.reloadData()
                }
            }
        }, completed: {
            delay {
                self.ownerRepoTableView.reloadData()
            }
        })
        
        // fetchUserStarredRepositories
        _ = client.fetchUserStarredRepositories().subscribeNext({ (repo) in
            if let repo = repo as? OCTRepository {
                debugPrint(repo)
                self.startRepos.append(repo)
                delay {
                    self.starRepoTableView.reloadData()
                }
            }
        }, completed: {
            delay {
                self.starRepoTableView.reloadData()
            }
        })
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
        self.performSegue(withIdentifier: "ShowRepoDetail", sender: repo)
    }

}
