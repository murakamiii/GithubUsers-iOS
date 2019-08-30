//
//  ViewController.swift
//  GithubUsers-iOS
//
//  Created by murakami Taichi on 2019/08/28.
//  Copyright © 2019 murakammm. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Foundation
import RxDataSources

enum APIError: Error, Equatable {
    case server
    case network
}

class ViewController: UIViewController {
    @IBOutlet private weak var usersTableView: UITableView!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        let nib = UINib(nibName: "UserCell", bundle: nil)
        usersTableView.register(nib, forCellReuseIdentifier: "userCell")
        self.navigationItem.title = "ユーザー一覧"
    }
    
    private func bindViewModel() {
        let observables = usersListViewModel(api: UserListAPI())
        
        observables
            .error
            .subscribe(onNext: { (err: APIError) in
                print(err)
            }).disposed(by: disposeBag)
        
        observables
            .users
            .bind(to: usersTableView.rx.items(cellIdentifier: "userCell", cellType: UserCell.self)) { _, user, cell in
                cell.setup(user)
            }.disposed(by: disposeBag)
        
        usersTableView.rx.modelSelected(GithubUser.self).subscribe { user in
            let vc = UserViewController.make(user: user.element!)
            self.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
}
