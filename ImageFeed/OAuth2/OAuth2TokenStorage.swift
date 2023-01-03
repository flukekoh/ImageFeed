//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Артем Кохан on 26.12.2022.
//

import Foundation

class OAuth2TokenStorage {
    private enum Keys: String {
        case token
    }
    private let userDefaults = UserDefaults.standard
    
    var token: String? {
        get {
            userDefaults.string(forKey: Keys.token.rawValue)
            }
        
        set {
            userDefaults.set(newValue, forKey: Keys.token.rawValue)
        }
    }
}
