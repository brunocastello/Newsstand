//
//  Library.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import Foundation
import Combine

class Library: ObservableObject, Identifiable {
    @Published var sidebarWidth: CGFloat = 272
    @Published var feedWidth: CGFloat = 350
    
    @Published var feeds: [Feed] = []
    
    @Published var addFeed: Feed?
    @Published var editFeed: Feed?
    
    @Published var searchQuery: String = ""
    
    private let userDefaultsKey = "savedFeeds"
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        load()
    }

    func load() {
        guard let savedFeeds = UserDefaults.standard.array(forKey: userDefaultsKey) as? [[String: String]] else { return }
        
        let loadedFeeds = savedFeeds.compactMap { feedDict -> Feed? in
            guard let idString = feedDict["id"],
                  let id = UUID(uuidString: idString),
                  let name = feedDict["name"],
                  let url = feedDict["url"] else {
                return nil
            }
            return Feed(id: id, name: name, url: url)
        }
        
        self.feeds = loadedFeeds

        let articleFetchPublishers = loadedFeeds.map { feed in
            RSSParser.fetchArticles(from: feed.url)
                .map { articles in
                    (feed, articles)
                }
                .catch { _ in Just((feed, [])) }
                .eraseToAnyPublisher()
        }
        Publishers.MergeMany(articleFetchPublishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                for (feed, articles) in results {
                    if let index = self?.feeds.firstIndex(where: { $0.id == feed.id }) {
                        self?.feeds[index].articles = articles
                    }
                }
            }
            .store(in: &cancellables)
    }

    func add(_ addFeed: Feed) {
        DispatchQueue.main.async {
            self.feeds.append(addFeed)
            self.save()
            self.fetchArticles(for: addFeed)
        }
    }

    func edit(_ editFeed: Feed) {
        DispatchQueue.main.async {
            if let index = self.feeds.firstIndex(where: { $0.id == editFeed.id }) {
                let originalFeed = self.feeds[index]
                
                self.feeds[index] = editFeed
                self.save()
                
                if originalFeed.url != editFeed.url {
                    self.fetchArticles(for: editFeed)
                }
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
            self.save()
        }
    }
    
    func move(fromOffsets indices: IndexSet, toOffset newOffset: Int) {
        DispatchQueue.main.async {
            self.feeds.move(fromOffsets: indices, toOffset: newOffset)
            self.save()
        }
    }

    func fetchArticles(for feed: Feed) {
        RSSParser.fetchArticles(from: feed.url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch articles for feed \(feed.name): \(error)")
                }
            }, receiveValue: { articles in
                if let index = self.feeds.firstIndex(where: { $0.id == feed.id }) {
                    self.feeds[index].articles = articles
                }
            })
            .store(in: &cancellables)
    }
        
    func search(feed: Feed?, search: String) -> [Article] {
        guard let feed = feed else { return [] }
        
        let articlesToFilter = feed.articles
        
        if search.isEmpty {
            return articlesToFilter
        } else {
            return articlesToFilter.filter { article in
                article.title.localizedCaseInsensitiveContains(search) ||
                article.description.localizedCaseInsensitiveContains(search) ||
                article.categories?.contains(where: { $0.localizedCaseInsensitiveContains(search) }) == true
            }
        }
    }
}
