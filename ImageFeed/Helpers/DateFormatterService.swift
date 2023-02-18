//
//  DateFormatter.swift
//  ImageFeed
//
//  Created by Артем Кохан on 08.02.2023.
//

import Foundation

final class DateFormatterService {
    static let shared = DateFormatterService()
    let isoFormatter = ISO8601DateFormatter()
    let formatter = DateFormatter()
    
    func getDateToString(date: Date) -> String {
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}


