//
//  Constants.swift
//  ImageFeed
//
//  Created by Артем Кохан on 25.12.2022.
//

import Foundation


let AccessKey = "DEU1dYszYBPS1mRYqBbwhJ39bnRiQNCtisfmn08jeEM"
let SecretKey = "5pV2UF1Q7-edPSPhV3CeO2sXkpFFKj2cig_hhGgEguA"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"
let DefaultBaseURL = URL(string: "https://api.unsplash.com")!

let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: AccessKey, secretKey: SecretKey, redirectURI: RedirectURI, accessScope: AccessScope, defaultBaseURL: DefaultBaseURL, authURLString: UnsplashAuthorizeURLString)
    }
    
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
   
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}
