//
//  MainViewModelTests.swift
//  GithubUsers-iOSTests
//
//  Created by murakami Taichi on 2019/08/29.
//  Copyright © 2019 murakammm. All rights reserved.
//

import XCTest
import RxBlocking
import RxSwift
import RxTest

@testable import GithubUsers_iOS

class MainViewModelTests: XCTestCase {
    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // とりあえずスモークテスト
    func test_mainViewModelFunc() {
        let stub = [
            GithubUser(login: "alice", id: 1, avatarUrl: URL(string: "https://example.com/img/1")!),
            GithubUser(login: "bob", id: 2, avatarUrl: URL(string: "https://example.com/img/2")!)
        ]
        let sub = PublishSubject<Void>.init()
        let event = sub.subscribeOn(MainScheduler.instance)
        let vm = UsersListViewModel(repository: UserListRepositoryStub(response: [.success(stub)]), scrollBottomEvent: event)
        XCTAssertEqual(try vm.users.toBlocking().first()?.count, 0)
        
        sub.on(.next(Void()))
        XCTAssertEqual(try vm.users.toBlocking().first()?.count, 2)
        
        var errValue: APIError?
        let err = vm.error.subscribe(onNext: { err in
                errValue = err
        })
        XCTAssertEqual(errValue, nil)
        err.disposed(by: disposeBag)
    }
    
    func test_mainViewModelFuncError() {
        let sub = PublishSubject<Void>.init()
        let event = sub.subscribeOn(MainScheduler.instance)
        
        let vm = UsersListViewModel(repository: UserListRepositoryStub(response: [.failure(.server)]), scrollBottomEvent: event)
        XCTAssertEqual(try vm.users.toBlocking().first()?.count, 0)
        let err = vm.error.subscribe(onNext: { err in
            XCTAssertEqual(err, APIError.server)
        })
        err.disposed(by: disposeBag)
    }
}
