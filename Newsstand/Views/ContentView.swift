//
//  ContentView.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var library = Library()
    
    @State private var editFeed: Feed?
    @State private var selectedFeed: Feed?
    
    @State private var articles: [Article] = []
    @State private var selectedArticle: Article?
    
    @State private var isShowingAddFeedView = false
    @State private var isShowingEditFeedView = false

    @State private var cancellables = Set<AnyCancellable>()
    
    let sidebarWidth: CGFloat = 272
    let feedWidth: CGFloat = 350

    var body: some View {
        NavigationSplitView {
            SidebarView(
                selectedFeed: $selectedFeed,
                editFeed: $editFeed,
                isShowingEditFeedView: $isShowingEditFeedView,
                articles: $articles,
                selectedArticle: $selectedArticle
            )
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        isShowingAddFeedView = true
                    }) {
                        Label("Add Feed", systemImage: "plus")
                    }
                    .help("Add Feed")
                }
            }
            .environmentObject(library)
            .navigationSplitViewColumnWidth(min: sidebarWidth, ideal: sidebarWidth, max: .infinity)
        } content: {
            if let feed = selectedFeed {
                FeedView(
                    selectedFeed: feed, 
                    articles: articles,
                    selectedArticle: $selectedArticle
                )
                .navigationSplitViewColumnWidth(min: feedWidth, ideal: feedWidth, max: .infinity)
            } else {
                Text("Select a feed")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(minWidth: feedWidth, maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        } detail: {
            if let selectedArticle = selectedArticle {
                ArticleView(article: selectedArticle)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            } else if selectedFeed != nil {
                Text("Select an article")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .environmentObject(library)
        .navigationSubtitle(selectedFeed?.name ?? "")
        .toolbar {
            if selectedFeed != nil {
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        refresh()
                    }) {
                        Label("Refresh Feed", systemImage: "arrow.clockwise")
                    }
                    .help("Refresh Feed")
                }
            }
        }
        .sheet(isPresented: $isShowingAddFeedView) {
            AddFeedView()
                .environmentObject(library)
        }
        .sheet(isPresented: $isShowingEditFeedView) {
            EditFeedView(feed: $editFeed)
                    .environmentObject(library)
        }
    }
    
    func refresh() {
        guard let selectedFeed = selectedFeed else {
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
}

#Preview {
    let library = Library()
    let sampleFeeds =
        [Feed(
            name: "Apple News",
            url: "https://www.apple.com/newsroom/rss-feed.rss"
        ),
         Feed(
             name: "TechCrunch",
             url: "http://feeds.feedburner.com/TechCrunch/"
         )]
    
    library.feeds = sampleFeeds
    
    return ContentView()
        .environmentObject(library)
}
