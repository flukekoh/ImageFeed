//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Артем Кохан on 26.12.2022.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
}
