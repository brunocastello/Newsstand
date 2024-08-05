//
//  Article.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import Foundation

struct Article: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let link: String
    let pubDate: String
    let creator: String
    let categories: [String]?

    init(title: String, description: String, link: String, pubDate: String, creator: String, categories: [String]? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.link = link
        self.pubDate = pubDate
        self.creator = creator
        self.categories = categories
    }

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case link
        case pubDate
        case creator
        case categories
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.link = try container.decode(String.self, forKey: .link)
        self.pubDate = try container.decode(String.self, forKey: .pubDate)
        self.creator = try container.decode(String.self, forKey: .creator)
        self.categories = try container.decodeIfPresent([String].self, forKey: .categories)
        self.id = UUID()
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
