//
//  GithubUser.swift
//  GithubUsers-iOS
//
//  Created by murakami Taichi on 2019/08/29.
//  Copyright © 2019 murakammm. All rights reserved.
//

import Foundation

struct GithubUser: Codable {
    var login: String
    var id: Int
    var avatarUrl: URL
}
