//
//  UserListRepository.swift
//  GithubUsers-iOS
//
//  Created by murakami Taichi on 2019/09/02.
//  Copyright © 2019 murakammm. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol UserListRepositoryProtocol {
    var users: BehaviorRelay<[GithubUser]> { get }
    var usersError: PublishRelay<APIError> { get }
    func callAppend() -> Completable
}

class UserListRepository: UserListRepositoryProtocol {
    private let api: UserListAPIProtocol
    private let disposeBag = DisposeBag()
    private var lastId = 0
    
    let users: BehaviorRelay<[GithubUser]> = BehaviorRelay<[GithubUser]>(value: [])
    let usersError: PublishRelay<APIError> = PublishRelay<APIError>()
    
    init(api: UserListAPIProtocol) {
        self.api = api
        
        let resp = api.users().materialize().share(replay: 1)
        resp.filter { (event: Event<[GithubUser]>) in
            event.element != nil
        }
        .map { $0.element! }
        .subscribe(onNext: {
            self.users.accept($0)
            self.lastId = $0.last?.id ?? 0
        }).disposed(by: disposeBag)
        
        let respError = resp.filter { (event: Event<[GithubUser]>) in
            event.error != nil
        }
        .map { $0.error as! APIError }
        respError.bind(to: usersError).disposed(by: disposeBag)
    }
    
    func callAppend() -> Completable {
        return Completable.create { completable in
            let resp = self.api.appendUsers(since: self.lastId).materialize().share(replay: 1)
            
            resp.filter { (event: Event<[GithubUser]>) in
                event.element != nil
            }
            .map { $0.element! }
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { (appendUser: [GithubUser]) in
                self.users.accept(self.users.value + appendUser)
                completable(.completed)
            })
            .disposed(by: self.disposeBag)
            
            resp.filter { (event: Event<[GithubUser]>) in
                event.error != nil
            }
            .map { (event) -> APIError in
                completable(.completed)
                return event.error as! APIError
            }
            .bind(to: self.usersError).disposed(by: self.disposeBag)
            
            return Disposables.create {}
        }
    }
}

class UserListRepositoryStub: UserListRepositoryProtocol {
    let users: BehaviorRelay<[GithubUser]> = BehaviorRelay<[GithubUser]>(value: [])
    let usersError: PublishRelay<APIError> = PublishRelay<APIError>()
    private var queue: [Result<[GithubUser], APIError>]
    
    init(response: [Result<[GithubUser], APIError>]) {
        queue = response
    }
    
    func callAppend() -> Completable {
        return Completable.create { completable in
            switch self.queue.first {
            case .none:
                self.users.accept(self.users.value + [])
            case .some(.failure(let err)):
                self.usersError.accept(err)
                self.queue.removeFirst()
            case .some(.success(let users)):
                self.users.accept(users)
                self.queue.removeFirst()
            }
            
            completable(.completed)
            return Disposables.create {}
        }
    }
}
