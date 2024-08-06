//
//  FeedView.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var library: Library
    
    let feed: Feed?

    var body: some View {
        if let feed = library.feeds.first(where: { $0.id == feed?.id }) {
            List {
                ForEach(library.search(feed: feed, search: library.searchQuery)) { article in
                    NavigationLink {
                        ArticleView(article: article)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)
                    } label: {
                        VStack(spacing: 0) {
                            Text(article.title)
                                .font(.headline)
                                .truncationMode(.tail)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom,4)
                            Text(article.pubDate)
                                .font(.caption)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.secondary)
                        }
                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 8, trailing: 5))
                    }
                }
            }
            .searchable(text: $library.searchQuery)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        library.fetchArticles(for: feed)
                    }) {
                        Label("Refresh Feed", systemImage: "arrow.clockwise")
                    }
                    .help("Refresh Feed")
                }
            }
            .navigationSubtitle(feed.name)
        } else {
            Text("Select a feed")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

#Preview {
    return FeedView(feed: nil)
        .environmentObject(Library())
}
