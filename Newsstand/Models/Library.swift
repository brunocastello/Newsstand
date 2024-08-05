//
//  Library.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import Foundation
import Combine

class Library: ObservableObject {
    @Published var feeds: [Feed] = []
    private let userDefaultsKey = "savedFeeds"

    init() {
        load()
    }

    private func load() {
        if let savedFeeds = UserDefaults.standard.array(forKey: userDefaultsKey) as? [[String: String]] {
            self.feeds = savedFeeds.compactMap { dict in
                if let idString = dict["id"],
                   let id = UUID(uuidString: idString),
                   let name = dict["name"],
                   let url = dict["url"] {
                    return Feed(id: id, name: name, url: url)
                }
                return nil
            }
        }
    }

    private func save() {
        let saveFeeds = feeds.map { feed in
            [
                "id": feed.id.uuidString,
                "name": feed.name,
                "url": feed.url
            ]
        }
        UserDefaults.standard.set(saveFeeds, forKey: userDefaultsKey)
    }
    
    func add(_ addFeed: Feed) {
        DispatchQueue.main.async {
            self.feeds.append(addFeed)
            self.save()
        }
    }

    func edit(_ editFeed: Feed) {
        DispatchQueue.main.async {
            if let index = self.feeds.firstIndex(where: { $0.id == editFeed.id }) {
                self.feeds[index] = editFeed
                self.save()
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        DispatchQueue.main.async {
            self.feeds.remove(atOffsets: offsets)
            self.save()
        }
    }

    func move(fromOffsets indices: IndexSet, toOffset newOffset: Int) {
        DispatchQueue.main.async {
            self.feeds.move(fromOffsets: indices, toOffset: newOffset)
            self.save()
        }
    }
}
