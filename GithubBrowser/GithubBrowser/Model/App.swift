//
//  App.swift
//
//  Create on 1/3/2017
//  Copyright © 2017 GMO Media, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class App: BaseModel {

    var clientId: String?
    var name: String?
    var url: String?

    override func mapping(map: Map) {
        super.mapping(map: map)
        clientId <- map["client_id"]
        name <- map["name"]
        url <- map["url"]        
    }

}
