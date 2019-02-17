//
//  User.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-06.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation

class User {
    var ID: String!
    var email: String!
    var provider
    init(ID: String, email: String) {
        self.ID = ID
        self.email = email
    }
}
