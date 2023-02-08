//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Артем Кохан on 26.12.2022.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private enum Keys: String {
        case token
    }
    private let userDefaults = UserDefaults.standard
    
    static let shared = OAuth2TokenStorage()
    
    var token: String? {
        get { KeychainWrapper.standard.string(forKey: "Auth token") }
        
        set {
            if let newValue {
                KeychainWrapper.standard.set(newValue, forKey: "Auth token")
            } else {
                KeychainWrapper.standard.removeObject(forKey: "Auth token")
            }
        }
    }
    
    func clearToken() {
        KeychainWrapper.standard.removeAllKeys()
    }
}
