//
//  Repo.swift
//  GithubUsers-iOS
//
//  Created by murakami Taichi on 2019/08/31.
//  Copyright © 2019 murakammm. All rights reserved.
//

import Foundation

struct Repo: Codable {
    var htmlUrl: URL
    var name: String
    var language: String?
    var stargazersCount: Int
    var description: String?
    var fork: Bool
}

extension Repo: Equatable {
    
}
