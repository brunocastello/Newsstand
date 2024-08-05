//
//  SidebarView.swift
//  Newsstand
//
//  Created by Bruno Castelló on 04/08/24.
//

import SwiftUI
import Combine

struct SidebarView: View {
    @EnvironmentObject var library: Library
    
    @Binding var selectedFeed: Feed?
    
    @Binding var editFeed: Feed?
    @Binding var isShowingEditFeedView: Bool
    
    @Binding var articles: [Article]
    @Binding var selectedArticle: Article?
    @State private var cancellables = Set<AnyCancellable>()
    
    @State private var isMoving: Bool = false

    var body: some View {
        List(selection: $selectedFeed) {
            Section {
                ForEach(library.feeds) { feed in
                    NavigationLink(
                        value: feed
                    ) {
                        HStack {
                            Image(systemName: "dot.radiowaves.up.forward")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(selectedFeed == feed ? .white : .accentColor)
                            Text(feed.name)
                                .truncationMode(.tail)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .contextMenu {
                        Button(action: {
                            editFeed = feed
                            isShowingEditFeedView = true
                        }) {
                            Text("Edit Feed")
                        }
                        Divider()
                        Button(action: {
                            if let index = library.feeds.firstIndex(of: feed) {
                                library.delete(at: IndexSet(integer: index))
                                if selectedFeed == feed {
                                    selectedFeed = nil
                                    selectedArticle = nil
                                }
                            }
                        }) {
                            Text("Delete Feed")
                        }
                    }
                }
                .onMove { indices, newOffset in
                    if selectedFeed != nil {
                        selectedFeed = nil
                    }
                    isMoving = true
                    moveFeeds(from: indices, to: newOffset)
                    isMoving = false
                }
            } header: {
                Text("Feeds")
                    .padding(.vertical, 4)
            }
            .collapsible(false)
        }
        .onChange(of: selectedFeed) {
            if let feed = selectedFeed {
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
    }
    
    private func moveFeeds(from source: IndexSet, to destination: Int) {
        library.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    // Sample data
    let sampleFeeds = [
        Feed(name: "Apple News", url: "https://www.apple.com/newsroom/rss-feed.rss"),
        Feed(name: "TechCrunch", url: "http://feeds.feedburner.com/TechCrunch/"),
    ]
    
    let sampleArticles = [
        Article(title: "Apple Releases New Product", description: "Apple has released a new product.", link: "http://apple.com", pubDate: "Sat, 03 Aug 2024 06:00:00 PDT", creator: "Apple Newsroom", categories: ["News", "Startups"]),
        Article(title: "Tech News Today", description: "Latest news in tech.", link: "http://techcrunch.com", pubDate: "Sat, 03 Aug 2024 06:00:00 PDT", creator: "TechCrunch", categories: ["News", "Startups"])
    ]

    let library = Library()
    library.feeds = sampleFeeds
    
    return SidebarView(
        selectedFeed: .constant(nil),
        editFeed: .constant(nil),
        isShowingEditFeedView: .constant(false),
        articles: .constant(sampleArticles),
        selectedArticle: .constant(nil)
    )
    .environmentObject(library)
}
