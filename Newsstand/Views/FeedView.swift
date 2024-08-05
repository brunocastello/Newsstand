//
//  FeedView.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import SwiftUI

struct FeedView: View {
    let selectedFeed: Feed
    let articles: [Article]
    
    @Binding var selectedArticle: Article?
    @State private var searchQuery: String = ""
    
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

    var body: some View {
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
        .navigationDestination(for: Article.self) { article in
            ArticleView(article: article)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    let sampleFeed = Feed(name: "Tech News", url: "https://www.technews.com/rss")
    
    let sampleArticles = [
        Article(
            title: "Tech Innovations of 2024",
            description: "Explore the latest tech innovations of 2024.",
            link: "https://www.technews.com/tech-innovations-2024",
            pubDate: "Fri, 02 Aug 2024 12:13:21 +0000",
            creator: "Tech News Team",
            categories: ["Technology", "Innovation"]
        ),
        Article(
            title: "AI Trends to Watch",
            description: "What are the biggest AI trends to look out for?",
            link: "https://www.technews.com/ai-trends",
            pubDate: "Sat, 03 Aug 2024 15:00:00 +0000",
            creator: "Tech News Team",
            categories: ["Technology", "AI"]
        )
    ]
    
    return FeedView(
        selectedFeed: sampleFeed,
        articles: sampleArticles,
        selectedArticle: .constant(nil)
    )
}
