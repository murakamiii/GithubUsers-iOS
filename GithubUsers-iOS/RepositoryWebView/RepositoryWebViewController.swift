//
//  RepositoryWebViewController.swift
//  GithubUsers-iOS
//
//  Created by murakami Taichi on 2019/09/02.
//  Copyright © 2019 murakammm. All rights reserved.
//

import Foundation
import UIKit


import WebKit
class RepoWebViewController: UIViewController, WKUIDelegate {
    static func make(url: URL) -> RepoWebViewController {
        let vc = RepoWebViewController()
        vc.repoUrl = url
        return vc
    }
    
    var webView: WKWebView!
    var repoUrl: URL!
    
    override func loadView() {
        let conf = WKWebViewConfiguration()
        webView = WKWebView.init(frame: .zero, configuration: conf)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myRequest = URLRequest(url: repoUrl)
        webView.load(myRequest)
    }
}
