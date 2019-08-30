//
//  RepoCell.swift
//  GithubUsers-iOS
//
//  Created by murakami Taichi on 2019/08/30.
//  Copyright © 2019 murakammm. All rights reserved.
//

import Foundation
import UIKit

class RepoCell: UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var langLabel: UILabel!
    @IBOutlet private weak var starLabel: UILabel!
    
    func setup(_ repo: Repo) {
        nameLabel.text = repo.name
        descriptionLabel.text = repo.description
        langLabel.text = repo.language
        starLabel.text = "⭐️ \(repo.stargazersCount)"
    }
}
