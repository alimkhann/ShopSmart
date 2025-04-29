//
//  UserModel.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 27/4/2025.
//

import Foundation

struct UserModel: Codable, Equatable {
    let userId: String
    var username: String?
    let email: String?
    let dateCreated: Date?
    let dateUpdated: Date?
    let photoUrl: String?
    let profileImagePath: String?
    let profileImagePathUrl: String?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.userId
        self.username = auth.username
        self.email = auth.email
        self.dateCreated = Date()
        self.dateUpdated = nil
        self.photoUrl = auth.photoUrl
        self.profileImagePath = nil
        self.profileImagePathUrl = nil
    }
}
