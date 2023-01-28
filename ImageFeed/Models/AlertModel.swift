//
//  AlertModel.swift
//  ImageFeed
//
//  Created by Артем Кохан on 28.01.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
