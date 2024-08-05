//
//  Feed.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import Foundation

struct Feed: Identifiable, Equatable, Hashable {
    var id: UUID
    var name: String
    var url: String

    init(id: UUID = UUID(), name: String, url: String) {
        self.id = id
        self.name = name
        self.url = url
    }

    init?(dict: [String: String]) {
        guard
            let idString = dict["id"],
            let id = UUID(uuidString: idString),
            let name = dict["name"],
            let url = dict["url"]
        else {
            return nil
        }
        self.id = id
        self.name = name
        self.url = url
    }

    func toDictionary() -> [String: String] {
        [
            "id": id.uuidString,
            "name": name,
            "url": url
        ]
    }
}
