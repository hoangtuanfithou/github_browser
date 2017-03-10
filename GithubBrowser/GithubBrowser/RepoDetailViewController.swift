//
//  RepoDetailViewController.swift
//  GithubBrowser
//
//  Created by Nguyen Hoang Tuan on 3/2/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import UIKit
import OctoKit
import SDWebImage
import SVProgressHUD

class RepoDetailViewController: UIViewController {

    var currentRepo: OCTRepository = OCTRepository()
    
    @IBOutlet weak var ownerAvatarImageView: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var commitsLabel: UILabel!
    @IBOutlet weak var branchesLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var contributorButton: UIButton!
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet weak var forkLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var starBarButton: UIBarButtonItem!
    
    @IBOutlet weak var openIssuesTableView: UITableView!
    @IBOutlet weak var closedIssuesTableView: UITableView!
    @IBOutlet weak var allIssuesTableView: UITableView!

    var openIssues = [OCTIssue]()
    var closedIssues = [OCTIssue]()
    var allIssues = [OCTIssue]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = currentRepo.name
        ownerAvatarImageView.sd_setImageWithIndicator(with: currentRepo.ownerAvatarURL)
        ownerNameLabel.text = currentRepo.ownerLogin
//        commitsLabel.text = currentRepo.comi
//        branchesLabel.text = currentRepo.defaultBranch
//        releaseLabel.text = currentRepo.ownerLogin
//        contributorLabel.text = currentRepo.contr
        starLabel.text = "Start: " + String(currentRepo.stargazersCount)
        forkLabel.text = "Fork: " + String(currentRepo.forksCount)
        languageLabel.text = "Languages: " + currentRepo.language
        
        fetchRepositoryIssuesInfo()
    }
    
    class func newController() -> RepoDetailViewController {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RepoDetailViewController") as! RepoDetailViewController
    }

    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // open
            view.bringSubview(toFront: openIssuesTableView)
        case 1: // closed
            view.bringSubview(toFront: closedIssuesTableView)
        case 2: // all
            view.bringSubview(toFront: allIssuesTableView)
        default:
            break
        }
    }
    
    @IBAction func starButtonAction(_ sender: Any) {
        if starBarButton.tintColor == .lightGray {
            starRepository()
        } else {
            unstarRepository()
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowOwnerUserViewController", let ownerUserView = segue.destination as? UserViewController {
            ownerUserView.userName = currentRepo.ownerLogin
        }
    }
    
    // MARK: Get Repo Info
    private func fetchRepositoryIssuesInfo() {
        guard let client = GithubAuthen.getGithubClientMine() else {
            return
        }
        
        _ = client.fetchIssues(for: currentRepo, state: .open, notMatchingEtag: nil, since: nil).subscribeNext({ response in
            if let response = response as? OCTResponse, let issue = response.parsedResult as? OCTIssue {
                self.openIssues.append(issue)
                self.openIssuesTableView.reloadOnMainQueue()
            }
        })
        
        _ = client.fetchIssues(for: currentRepo, state: .closed, notMatchingEtag: nil, since: nil).subscribeNext({ response in
            if let response = response as? OCTResponse, let issue = response.parsedResult as? OCTIssue {
                self.closedIssues.append(issue)
                self.closedIssuesTableView.reloadOnMainQueue()
            }
        })
        
        _ = client.fetchIssues(for: currentRepo, state: .all, notMatchingEtag: nil, since: nil).subscribeNext({ response in
            if let response = response as? OCTResponse, let issue = response.parsedResult as? OCTIssue {
                self.allIssues.append(issue)
                self.allIssuesTableView.reloadOnMainQueue()
            }
        })
        
        _ = client.hasUserStarredRepository(currentRepo).subscribeNext( { [weak self] response in
            if let response = response as? NSNumber {
                delay {
                    self?.starBarButton.tintColor = response.boolValue ? .green : .lightGray
                }
            }
        }, error: { error in
        }, completed: {
        })
    }

    // MARK: Star/UnStar function
    private func starRepository() {
        guard let client = GithubAuthen.getGithubClientMine() else {
            return
        }
        _ = client.starRepository(currentRepo).subscribeNext({ response in
        }, error: { error in
        }, completed: { [weak self] in
            delay {
                self?.starBarButton.tintColor = .green
            }
        })
    }
    
    private func unstarRepository() {
        guard let client = GithubAuthen.getGithubClientMine() else {
            return
        }
        _ = client.unstarRepository(currentRepo).subscribeNext({ response in
            
        }, error: { error in
        }, completed: { [weak self] in
            delay {
                self?.starBarButton.tintColor = .lightGray
            }
        })
    }
    
}

extension RepoDetailViewController: UITableViewDataSource {
    
    private func getIssueArray(forTableView tableView: UITableView) -> [OCTIssue] {
        switch tableView {
        case openIssuesTableView:
            return openIssues
        case closedIssuesTableView:
            return closedIssues
        case allIssuesTableView:
            return allIssues
        default:
            return []
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getIssueArray(forTableView: tableView).count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IssuesTableViewCell", for: indexPath)
        let issue = getIssueArray(forTableView: tableView)[indexPath.row]
        cell.textLabel?.text = issue.title
        cell.detailTextLabel?.text = issue.number
        return cell
    }
    
}
