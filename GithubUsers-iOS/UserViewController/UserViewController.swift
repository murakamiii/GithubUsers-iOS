//
//  UserViewController.swift
//  GithubUsers-iOS
//
//  Created by murakami Taichi on 2019/08/30.
//  Copyright © 2019 murakammm. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import Nuke

class UserViewController: UIViewController {
    var user: GithubUser!
    
    static func make(user: GithubUser) -> UserViewController {
        let storyboard = UIStoryboard.init(name: "User", bundle: .main)
        let vc = storyboard.instantiateInitialViewController() as! UserViewController
        vc.user = user
        
        return vc
    }
    
    @IBOutlet private weak var loginLabel: UILabel!
    @IBOutlet private weak var fullnameLabel: UILabel!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var followersLabel: UILabel!
    @IBOutlet private weak var followingLabel: UILabel!
    @IBOutlet private weak var reposTableView: UITableView!
    
    @IBOutlet private weak var avatarHeightConstraint: NSLayoutConstraint!
    let avatarMaxHeight: CGFloat = 160.0
    let avatarMinHeight: CGFloat = 48.0
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupUI() {
        self.navigationItem.title = user.login
        loginLabel.text = user.login
        Nuke.loadImage(with: user.avatarUrl, into: avatarImageView)
        avatarImageView.layer.cornerRadius = 8.0
        avatarImageView.clipsToBounds = true
        
        let nib = UINib(nibName: "RepoCell", bundle: nil)
        reposTableView.register(nib, forCellReuseIdentifier: "RepoCell")
        
        reposTableView.rx.contentOffset.subscribe(onNext: {[weak self] offset in
            guard let self = self else { return }
            let fixedheight = max(self.avatarMaxHeight - offset.y, self.avatarMinHeight)
            self.avatarHeightConstraint.constant = fixedheight
        }).disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let observables = userViewModel(api: DetailAPI(), login: user.login)
        
        observables
            .error
            .subscribe(onNext: { err in
                print(err)
            }).disposed(by: disposeBag)
        
        observables
            .detail
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] detail in
                guard let self = self else {
                    return
                }
                self.fullnameLabel.text = detail.name
                self.followersLabel.text = "Followers: \(detail.followers)"
                self.followingLabel.text = "Following: \(detail.following)"
            }).disposed(by: disposeBag)
        
        observables
            .repos
            .bind(to: reposTableView.rx.items(cellIdentifier: "RepoCell", cellType: RepoCell.self)) { _, repo, cell in
                cell.setup(repo)
            }.disposed(by: disposeBag)
        
        reposTableView.rx.modelSelected(Repo.self).subscribe { repo in
            let vc = RepoWebViewController.make(url: repo.element!.htmlUrl)
            self.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
}

func userViewModel(api: UserDetailAPIProtocol, login: String) -> (detail: Observable<GithubUserDetail>, repos: Observable<[Repo]>, error: Observable<APIError>) {
    let resp = api.user(login: login).materialize().share(replay: 1)
    let resp2 = api.repos(login: login).materialize().share(replay: 1)
    
    let detail = resp.filter { (event: Event<GithubUserDetail>) in
        event.element != nil
    }.map { $0.element! }
    
    let repos = resp2.filter { (event: Event<[Repo]>) in
        event.element != nil
    }.map { $0.element! }
    
    let error = resp.filter { (event: Event<GithubUserDetail>) in
        event.error != nil
    }.map { $0.error as! APIError }
    
    let repoErr = resp2.filter { (event: Event<[Repo]>) in
        event.error != nil
    }.map { $0.error as! APIError }
    
    return (detail, repos, error)
}
