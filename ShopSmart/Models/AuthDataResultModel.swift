//
//  AuthDataResultModel.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 27/4/2025.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let userId: String
    let username: String?
    let email: String?
    let photoUrl: String?
    
    init(user: User) {
        self.username = user.displayName
        self.userId = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}
