//
//  GithubAPI.swift
//  GithubUsers-iOS
//
//  Created by murakami Taichi on 2019/08/29.
//  Copyright © 2019 murakammm. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Reachability

protocol UserListAPIProtocol {
    func users() -> Observable<[GithubUser]>
    func appendUsers(since: Int) -> Observable<[GithubUser]>
}

class UserListAPI: UserListAPIProtocol {
    let session = URLSession.shared
    
    func users() -> Observable<[GithubUser]> {
        let url = URL(string: "https://api.github.com/users")!
        var req = URLRequest(url: url)
        if let token = ProcessInfo.processInfo.environment["personal_access_token"] {
            req.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if Reachability()!.connection == .none {
            return Observable<[GithubUser]>.create { obs in
                obs.onError(APIError.network)
                return Disposables.create {}
            }
        }
        return session.rx.response(request: req).map { resp, data in
            if resp.statusCode == 403, let remain = resp.allHeaderFields["X-RateLimit-Remaining"] as? String, remain == "0" {
                throw APIError.rateLimit
            }
            if resp.statusCode != 200 {
                throw APIError.server
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let decoded = try? decoder.decode([GithubUser].self, from: data) {
                return decoded
            } else {
                throw APIError.server
            }
        }
    }
    
    func appendUsers(since sinceId: Int) -> Observable<[GithubUser]> {
        let url = URL(string: "https://api.github.com/users?since=\(sinceId)")!
        var req = URLRequest(url: url)
        if let token = ProcessInfo.processInfo.environment["personal_access_token"] {
            req.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if Reachability()!.connection == .none {
            return Observable<[GithubUser]>.create { obs in
                obs.onError(APIError.network)
                return Disposables.create {}
            }
        }
        return session.rx.response(request: req).map { resp, data in
            if resp.statusCode == 403, let remain = resp.allHeaderFields["X-RateLimit-Remaining"] as? String, remain == "0" {
                throw APIError.rateLimit
            }
            if resp.statusCode != 200 {
                throw APIError.server
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let decoded = try? decoder.decode([GithubUser].self, from: data) {
                return decoded
            } else {
                throw APIError.server
            }
        }
    }
}

class UserListAPIStub: UserListAPIProtocol {
    func appendUsers(since: Int) -> Observable<[GithubUser]> {
        fatalError()
    }
    
    let stub: [GithubUser]
    init(users: [GithubUser]) {
        stub = users
    }

    func users() -> Observable<[GithubUser]> {
        return Observable.of(stub)
    }
}

class UserListAPIErrorStub: UserListAPIProtocol {
    func appendUsers(since: Int) -> Observable<[GithubUser]> {
        fatalError()
    }
    
    func users() -> Observable<[GithubUser]> {
        return Observable<[GithubUser]>.create { ob in
            ob.onError(APIError.server)
            return Disposables.create()
        }
    }
}
