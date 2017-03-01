//
//  AuthorizationsResponse.swift
//
//  Create on 1/3/2017
//  Copyright © 2017 GMO Media, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class AuthorizationsResponse: BaseModel {

    var app: App?
    var createdAt: String?
    var fingerprint: AnyObject?
    var hashedToken: String?
    var id: Int?
    var note: String?
    var noteUrl: AnyObject?
    var scopes: [String]?
    var token: String?
    var tokenLastEight: String?
    var updatedAt: String?
    var url: String?

    override func mapping(map: Map) {
        super.mapping(map: map)
        app <- map["app"]
        createdAt <- map["created_at"]
        fingerprint <- map["fingerprint"]
        hashedToken <- map["hashed_token"]
        id <- map["id"]
        note <- map["note"]
        noteUrl <- map["note_url"]
        scopes <- map["scopes"]
        token <- map["token"]
        tokenLastEight <- map["token_last_eight"]
        updatedAt <- map["updated_at"]
        url <- map["url"]        
    }

}
