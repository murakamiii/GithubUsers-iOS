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
import UIKit

class UsersListViewModel {
    private let repository: UserListRepositoryProtocol
    private let disposeBag = DisposeBag()
    
    let users: Observable<[GithubUser]>
    let error: Observable<APIError>
    let isLoading: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    
    init(repository: UserListRepositoryProtocol, scrollBottomEvent: Observable<Void>) {
        self.repository = repository
        users = repository.users.asObservable()
        error = repository.usersError.asObservable()
        
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
