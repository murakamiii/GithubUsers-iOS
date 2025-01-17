//
//  APIError.swift
//  GithubUsers-iOS
//
//  Created by murakami Taichi on 2019/09/03.
//  Copyright © 2019 murakammm. All rights reserved.
//

import Foundation

enum APIError: Error, Equatable {
    case server
    case network
    case application
    case rateLimit
    
    func message() -> String {
        switch self {
        case .server:
            return "サーバー側に問題が発生しているようです。"
        case .network:
            return "ネットワーク環境に問題があります。"
        case .application:
            return "アプリ側に問題があります。"
        case .rateLimit:
            return "アクセス回数の制限に到達しました。"
        }
    }
}
