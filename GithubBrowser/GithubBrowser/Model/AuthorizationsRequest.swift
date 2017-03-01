//
//  AuthorizationsRequest.swift
//
//  Create on 1/3/2017
//  Copyright © 2017 GMO Media, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class AuthorizationsRequest: BaseModel {

    var clientId: String?
    var clientSecret: String?
    var note: String?
    var scopes: [String]?

    override func mapping(map: Map) {
        super.mapping(map: map)
        clientId <- map["client_id"]
        clientSecret <- map["client_secret"]
        note <- map["note"]
        scopes <- map["scopes"]        
    }

}
