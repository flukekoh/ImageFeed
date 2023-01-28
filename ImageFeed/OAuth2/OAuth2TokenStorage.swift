//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Артем Кохан on 26.12.2022.
//

import Foundation
import SwiftKeychainWrapper

class OAuth2TokenStorage {
    private enum Keys: String {
        case token
    }
    private let userDefaults = UserDefaults.standard
    
    var token: String? {
        get {
//            userDefaults.string(forKey: Keys.token.rawValue)
            
            KeychainWrapper.standard.string(forKey: "Auth token")
            }
        
        set {
//            userDefaults.set(newValue, forKey: Keys.token.rawValue)
            
            guard let newValue = newValue else {return}
            
            let isSuccess = KeychainWrapper.standard.set(newValue, forKey: "Auth token")
           
            guard isSuccess else {
                return
                // ошибка
            }
        }
    }
}
