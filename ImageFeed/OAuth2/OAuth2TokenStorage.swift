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
    
    var token: String? {
        get { KeychainWrapper.standard.string(forKey: "Auth token") }
        
        set {
            guard let newValue = newValue else {
                KeychainWrapper.standard.removeObject(forKey: "Auth token")
                return
            }
            let isSuccess = KeychainWrapper.standard.set(newValue, forKey: "Auth token")
            guard isSuccess else { return }
        }
    }
}
