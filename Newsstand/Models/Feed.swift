//
//  Feed.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import Foundation

struct Feed: Identifiable, Equatable, Hashable {
    var id = UUID()
    var name: String = ""
    var url: String = ""

    func toDictionary() -> [String: String] {
        [
            "id": id.uuidString,
            "name": name,
            "url": url
        ]
    }
}
