//
//  MainViewModel.swift
//  GithubUsers-iOS
//
//  Created by murakami Taichi on 2019/08/29.
//  Copyright © 2019 murakammm. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

func usersListViewModel(api: GithubAPIProtocol) -> (users: Observable<[GithubUser]>, error: Observable<APIError>) {
    let resp = api.users().materialize().share(replay: 1)
    
    let users = resp.filter { (event: Event<[GithubUser]>) in
        event.element != nil
    }.map { $0.element! }
    
    let error = resp.filter { (event: Event<[GithubUser]>) in
        event.error != nil
    }.map { $0.error as! APIError }
    
    return (users, error)
}
