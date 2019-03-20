//
//  FlickrAttribution-Client.swift
//  dogFinder
//
//  Created by Frank Aceves on 3/17/19.
//  Copyright © 2019 Frank Aceves. All rights reserved.
//

import Foundation
struct Result: Codable {
    let stat: String
    let photo: PhotoInfo
}

struct PhotoInfo: Codable  {
    let id: String
    let urls: Urls
    let owner: Owner
}

struct Owner: Codable {
    let username: String
}

struct Urls: Codable  {
    let url: [Url]
}

struct Url: Codable  {
    let type: String
    let _content: String
}
