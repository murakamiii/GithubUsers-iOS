//
//  UserDetailViewModelTests.swift
//  GithubUsers-iOSTests
//
//  Created by murakami Taichi on 2019/09/03.
//  Copyright © 2019 murakammm. All rights reserved.
//

import XCTest
import Foundation
import RxBlocking
import RxSwift
import RxTest

@testable import GithubUsers_iOS
class UserDetailViewModelTests: XCTestCase {
    let disposeBag = DisposeBag()
    let scheduler = TestScheduler(initialClock: 0)
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    let detailStub = GithubUserDetail(name: "test_tarou", followers: 12, following: 123, publicRepos: 3)
    let repo1 = Repo(htmlUrl: URL(string: "https://github.com/mojombo/yaws")!, name: "yaws", language: "Erlang", stargazersCount: 123, description: "YAWS is an erlang web server", fork: false)
    let repo2 = Repo(htmlUrl: URL(string: "https://github.com/mojombo/min")!, name: "min", language: nil, stargazersCount: 0, description: nil, fork: true)
    let repo3 = Repo(htmlUrl: URL(string: "https://github.com/mojombo/max")!, name: "max", language: "JavaScript", stargazersCount: 99_999, description: "aaa", fork: false)

    // とりあえずスモークテスト
    func test_UserDetailViewModelFunc() {
        let scheduler = TestScheduler(initialClock: 0)
        let repos = scheduler.createObserver([Repo].self)
        let tap = scheduler.createColdObservable([.next(10, Void())])

        let vm = UserDetailViewModel(repository: UserDetailRepositoryStub(repos: [.success([repo1, repo2]), .success([repo3])], detail: detailStub),
                                     scrollBottomEvent: tap.asObservable())
        XCTAssertEqual(try vm.detail.toBlocking().first()?.name, "test_tarou")

        vm.repos.asDriver(onErrorJustReturn: []).drive(repos).disposed(by: disposeBag)
        scheduler.start()
        let expect: [Recorded<Event<[Repo]>>] = [Recorded.next(0, []), Recorded.next(10, [repo1])]
        XCTAssertEqual(repos.events, expect)
    }
    
    func test_UserDetailViewModelFuncError() {
        let sub = PublishSubject<Void>()
        let event = sub.subscribeOn(MainScheduler.instance)
        
        let vm = UserDetailViewModel(repository: UserDetailRepositoryStub(repos: [.failure(APIError.network)], detail: detailStub),
                                     scrollBottomEvent: event)
        XCTAssertEqual(try vm.repos.toBlocking().first()?.count, 0)
        let err = vm.error.subscribe(onNext: { err in
            XCTAssertEqual(err, APIError.network)
        })
        err.disposed(by: disposeBag)
    }
}
