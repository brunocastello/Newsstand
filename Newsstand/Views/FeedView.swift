//
//  FeedView.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var library: Library
    
    @State private var searchQuery: String = ""
    
    var filteredArticles: [Article] {
        if searchQuery.isEmpty {
            return library.articles
        } else {
            return library.articles.filter { article in
                article.title.localizedCaseInsensitiveContains(searchQuery) ||
                article.description.localizedCaseInsensitiveContains(searchQuery) ||
                article.categories?.contains(where: { $0.localizedCaseInsensitiveContains(searchQuery) }) == true
            }
        }
    }

    var body: some View {
        if library.selectedFeed != nil {
            List(filteredArticles, id: \.id) { article in
                NavigationLink(
                    value: article
                ) {
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
            .searchable(text: $searchQuery)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        library.refresh()
                    }) {
                        Label("Refresh Feed", systemImage: "arrow.clockwise")
                    }
                    .help("Refresh Feed")
                }
            }
            .navigationDestination(for: Article.self) { article in
                ArticleView(article: article)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
            }
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
    return FeedView()
        .environmentObject(Library())
}
