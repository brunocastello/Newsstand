//
//  Library.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import Foundation
import Combine

@MainActor
class Library: ObservableObject, Identifiable {
    @Published var feeds: [Feed] = []
    @Published var articles: [Article] = []
    
    @Published var addFeed: Feed?
    @Published var editFeed: Feed?
    
    @Published var selectedFeed: Feed?
    @Published var selectedArticle: Article?
    
    private let userDefaultsKey = "savedFeeds"
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        load()
    }

    func load() {
        guard let feeds = UserDefaults.standard.array(forKey: userDefaultsKey) as? [[String: String]] else { return }
        
        self.feeds = feeds.compactMap { feed in
            if let idString = feed["id"],
               let id = UUID(uuidString: idString),
               let name = feed["name"],
               let url = feed["url"] {
                return Feed(id: id, name: name, url: url)
            }
            return nil
        }
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

    func save() {
        let saveFeeds = feeds.map { feed in [
            "id": feed.id.uuidString,
            "name": feed.name,
            "url": feed.url
        ]}
        
        UserDefaults.standard.set(saveFeeds, forKey: userDefaultsKey)
    }

    func delete(feed: Feed) {
        DispatchQueue.main.async {
            self.feeds.removeAll(where: { $0.id == feed.id })
            if self.selectedFeed == feed {
                self.selectedFeed = nil
                self.selectedArticle = nil
            }
            self.save()
        }
    }
    
    @Published var isMoving: Bool = false
    
    func move(fromOffsets indices: IndexSet, toOffset newOffset: Int) {
        isMoving = true
        self.feeds.move(fromOffsets: indices, toOffset: newOffset)
        self.save()
        isMoving = false
    }

    func fetchArticles() {
        if let feed = self.selectedFeed {
            RSSParser.fetchArticles(from: feed.url)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // Implement logic for fail in fetching articles
                        print("Failed to fetch articles: \(error)")
                    }
                }, receiveValue: { articles in
                    self.articles = articles
                })
                .store(in: &cancellables)
        } else {
            self.articles = []
        }
    }
    
    func refreshArticles() {
        guard let selectedFeed = self.selectedFeed else {
            print("No feed selected")
            return
        }
        
        RSSParser.fetchArticles(from: selectedFeed.url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to refresh feed \(selectedFeed.name): \(error)")
                }
            }, receiveValue: { newArticles in
                self.articles = newArticles
            })
            .store(in: &cancellables)
    }
    
    @Published var searchQuery: String = ""
        
    var filteredArticles: [Article] {
        if searchQuery.isEmpty {
            return articles
        } else {
            return articles.filter { article in
                article.title.localizedCaseInsensitiveContains(searchQuery) ||
                article.description.localizedCaseInsensitiveContains(searchQuery) ||
                article.categories?.contains(where: { $0.localizedCaseInsensitiveContains(searchQuery) }) == true
            }
        }
    }
}
