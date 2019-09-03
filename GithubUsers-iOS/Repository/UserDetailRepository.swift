//
//  UserDetailRepository.swift
//  GithubUsers-iOS
//
//  Created by murakami Taichi on 2019/09/03.
//  Copyright © 2019 murakammm. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol UserDetailRepositoryProtocol {
    var detail: BehaviorRelay<GithubUserDetail?> { get }
    var repos: BehaviorRelay<[Repo]> { get }
    var error: PublishRelay<APIError> { get }
    
    func callAppend() -> Completable
}

class UserDetailRepository: UserDetailRepositoryProtocol {
    private let login: String
    private let api: UserDetailAPIProtocol
    private let disposeBag = DisposeBag()
    private var lastPage = 1
    
    let detail: BehaviorRelay<GithubUserDetail?> = BehaviorRelay<GithubUserDetail?>(value: nil)
    let repos: BehaviorRelay<[Repo]> = BehaviorRelay<[Repo]>(value: [])
    let error: PublishRelay<APIError> = PublishRelay<APIError>()
    
    init(api: UserDetailAPIProtocol, login: String) {
        self.api = api
        self.login = login
        
        let detail = api.user(login: login).materialize().share(replay: 1)
        detail.filter { (event: Event<GithubUserDetail>) in
            event.element != nil
        }
        .map { $0.element! }
        .subscribe(onNext: {
            self.detail.accept($0)
        })
        .disposed(by: disposeBag)
        
        detail.filter { (event: Event<GithubUserDetail>) in
            event.error != nil
        }
        .map { $0.error as! APIError }
        .bind(to: self.error)
        .disposed(by: disposeBag)
        
        let repos = api.repos(login: login).materialize().share(replay: 1)
        repos.filter { (event: Event<[Repo]>) in
            event.element != nil
        }
        .map { $0.element! }
        .subscribe(onNext: {
            self.repos.accept($0)
            if !$0.isEmpty { self.lastPage += 1 }
        })
        .disposed(by: disposeBag)
        
        repos.filter { (event: Event<[Repo]>) in
            event.error != nil
        }
        .map { $0.error as! APIError }
        .bind(to: self.error)
        .disposed(by: disposeBag)
    }
    
    func callAppend() -> Completable {
        return Completable.create { completable in
            if let detail = self.detail.value, detail.publicRepos <= self.repos.value.count {
                return Disposables.create {}
            }
            
            let resp = self.api.appendRepos(login: self.login, page: self.lastPage).materialize().share(replay: 1)
            
            resp.filter { (event: Event<[Repo]>) in
                event.element != nil
            }
            .map { $0.element! }
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { (appendRepos: [Repo]) in
                self.repos.accept(self.repos.value + appendRepos)
                self.lastPage += 1
                completable(.completed)
            })
            .disposed(by: self.disposeBag)
            
            resp.filter { (event: Event<[Repo]>) in
                event.error != nil
            }
            .map { (event) -> APIError in
                completable(.completed)
                return event.error as? APIError ?? APIError.application
            }
            .bind(to: self.error).disposed(by: self.disposeBag)
            
            return Disposables.create {}
        }
    }
}

class UserDetailRepositoryStub: UserDetailRepositoryProtocol {
    var detail: BehaviorRelay<GithubUserDetail?> = BehaviorRelay<GithubUserDetail?>(value: nil)
    var repos: BehaviorRelay<[Repo]> = BehaviorRelay<[Repo]>(value: [])
    var error: PublishRelay<APIError> = PublishRelay<APIError>()
    
    private var queue: [Result<[Repo], APIError>]
    
    init(repos: [Result<[Repo], APIError>], detail: GithubUserDetail) {
        self.queue = repos
        self.detail.accept(detail)
    }
    
    func callAppend() -> Completable {
        return Completable.create { completable in
            switch self.queue.first {
            case .none:
                self.repos.accept(self.repos.value + [])
            case .some(.failure(let err)):
                self.error.accept(err)
                self.queue.removeFirst()
            case .some(.success(let repos)):
                self.repos.accept(self.repos.value + repos)
                self.queue.removeFirst()
            }
            
            completable(.completed)
            return Disposables.create {}
        }
    }
}
