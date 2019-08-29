//
//  MainViewModelTests.swift
//  GithubUsers-iOSTests
//
//  Created by murakami Taichi on 2019/08/29.
//  Copyright © 2019 murakammm. All rights reserved.
//

import XCTest
import RxBlocking

@testable import GithubUsers_iOS

class MainViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // とりあえずスモークテスト
    func test_mainViewModelFunc() {
        let stub = GithubAPIStub(users: [
            GithubUser(login: "alice", id: 1, avatarUrl: URL(string: "https://example.com/img/1")!),
            GithubUser(login: "bob", id: 2, avatarUrl: URL(string: "https://example.com/img/2")!),
        ])
        let vm = usersListViewModel(api: stub)
        XCTAssertEqual(try vm.users.toBlocking().first()?.count, 2)
        XCTAssertEqual(try vm.error.toBlocking().first(), nil)
    }
    
    func test_mainViewModelFuncError() {
        let stub = GithubAPIErrorStub()
        let vm = usersListViewModel(api: stub)
        XCTAssertEqual(try vm.users.toBlocking().first()?.count, nil)
        XCTAssertEqual(try vm.error.toBlocking().first(), APIError.server)
    }
}
