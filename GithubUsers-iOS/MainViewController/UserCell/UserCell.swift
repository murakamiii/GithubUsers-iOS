//
//  UserCell.swift
//  GithubUsers-iOS
//
//  Created by murakami Taichi on 2019/08/29.
//  Copyright © 2019 murakammm. All rights reserved.
//

import Foundation
import UIKit
import Nuke

class UserCell: UITableViewCell {
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userIconImageView.layer.cornerRadius = 4.0
        userIconImageView.clipsToBounds = true
    }
    
    func setup(_ user: GithubUser) {
        Nuke.loadImage(with: user.avatarUrl, into: userIconImageView)
        userNameLabel.text = user.login
    }
}
