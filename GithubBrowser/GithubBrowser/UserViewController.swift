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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowLoginView", let loginView = segue.destination as? LoginViewController {
            loginView.loginCallback = { (result, user) in
                if result {
                    self.dismiss(animated: true, completion: nil)
                    self.getUserInfo()
                }
            }
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
        _ = client.fetchUserInfo().subscribeNext({ (user) in
            if let user = user as? OCTUser {
                self.displayUserInfo(user: user)
            }
        })
        
        // fetchUserRepositories
        _ = client.fetchUserRepositories().subscribeNext({ (repo) in
            if let repo = repo as? OCTRepository {
                debugPrint(repo)
                self.ownerRepos.append(repo)
                self.ownerRepoTableView.reloadData()
            }
        }, completed: {
        })
        
        // fetchUserStarredRepositories
        _ = client.fetchUserStarredRepositories().subscribeNext({ (repo) in
            if let repo = repo as? OCTRepository {
                debugPrint(repo)
                self.startRepos.append(repo)
                self.ownerRepoTableView.reloadData()
            }
        }, completed: {
            self.starRepoTableView.reloadData()
        })
    }
    
}

extension UserViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == ownerRepoTableView ? ownerRepos.count : startRepos.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = tableView == ownerRepoTableView ? "OwnerTableViewCell" : "StarTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let repo = tableView == ownerRepoTableView ? ownerRepos[indexPath.row] : startRepos[indexPath.row]
        cell.textLabel?.text = repo.name
        return cell
    }

}
