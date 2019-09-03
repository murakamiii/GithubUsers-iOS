//
//  UserDetailViewModel.swift
//  GithubUsers-iOS
//
//  Created by murakami Taichi on 2019/09/03.
//  Copyright © 2019 murakammm. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UserDetailViewModel {
    private let repository: UserDetailRepositoryProtocol
    private let disposeBag = DisposeBag()
    
    let detail: Observable<GithubUserDetail>
    let repos: Observable<[Repo]>
    let error: Observable<APIError>
    let isLoading: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    
    init(repository: UserDetailRepositoryProtocol, scrollBottomEvent: Observable<Void>) {
        self.repository = repository
        detail = repository.detail.asObservable().filter { $0 != nil }.map { $0! }
        repos = repository.repos.asObservable().map { $0.filter({ repo -> Bool in repo.fork == false }) }
        error = repository.error.asObservable()
        
        scrollBottomEvent.subscribe(onNext: { _ in
            if self.isLoading.value == true {
                return
            }
            self.repository.callAppend().subscribe(onCompleted: {
                self.isLoading.accept(false)
            }).disposed(by: self.disposeBag)
            self.isLoading.accept(true)
        }).disposed(by: disposeBag)
    }
}
