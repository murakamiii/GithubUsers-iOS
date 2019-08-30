//
//  UserDetail.swift
//  GithubUsers-iOS
//
//  Created by murakami Taichi on 2019/08/31.
//  Copyright © 2019 murakammm. All rights reserved.
//

import Foundation

struct GithubUserDetail: Codable {
    var name: String?
    var followers: Int
    var following: Int
}
