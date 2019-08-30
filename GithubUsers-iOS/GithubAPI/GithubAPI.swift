//
//  GithubAPI.swift
//  GithubUsers-iOS
//
//  Created by murakami Taichi on 2019/08/29.
//  Copyright © 2019 murakammm. All rights reserved.
//

import Foundation
import RxSwift

protocol GithubAPIProtocol {
    func users() -> Observable<[GithubUser]>
}

class GithubAPI: GithubAPIProtocol {
    let session = URLSession.shared
    
    func users() -> Observable<[GithubUser]> {
        let url = URL(string: "https://api.github.com/users")!
        let req = URLRequest(url: url)
        
        return session.rx.response(request: req).map { resp, data in
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

class GithubAPIStub: GithubAPIProtocol {
    let stub: [GithubUser]
    init(users: [GithubUser]) {
        stub = users
    }

    func users() -> Observable<[GithubUser]> {
        return Observable.of(stub)
    }
}

class GithubAPIErrorStub: GithubAPIProtocol {
    func users() -> Observable<[GithubUser]> {
        return Observable<[GithubUser]>.create { ob in
            ob.onError(APIError.server)
            return Disposables.create()
        }
    }
}


struct GithubUserDetail: Codable {
    var name: String?
    var followers: Int
    var following: Int
}

struct Repo: Codable {
    var htmlUrl: URL
    var name: String
    var language: String?
    var stargazersCount: Int
    var description: String?
}

protocol UserDetailAPIProtocol {
    func user(login: String) -> Observable<GithubUserDetail>
    func repos(login: String) -> Observable<[Repo]>
}

class DetailAPI: UserDetailAPIProtocol {
    let session = URLSession.shared
    
    func user(login: String) -> Observable<GithubUserDetail> {
        let url = URL(string: "https://api.github.com/users/\(login)")!
        let req = URLRequest(url: url)
        
        return session.rx.response(request: req).map { resp, data in
            if resp.statusCode != 200 {
                throw APIError.server
            }
            
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(GithubUserDetail.self, from: data) {
                return decoded
            } else {
                throw APIError.server
            }
        }
    }
    
    func repos(login: String) -> Observable<[Repo]> {
        let url = URL(string: "https://api.github.com/users/\(login)/repos")!
        let req = URLRequest(url: url)
        
        return session.rx.response(request: req).map { resp, data in
            if resp.statusCode != 200 {
                throw APIError.server
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let decoded = try? decoder.decode([Repo].self, from: data) {
                return decoded
            } else {
                throw APIError.server
            }
        }
    }
}
