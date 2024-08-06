//
//  FeedView.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var library: Library

    var body: some View {
        if library.selectedFeed != nil {
            List(selection: $library.selectedArticle) {
                ForEach(library.filteredArticles) { article in
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
            }
            .searchable(text: $library.searchQuery)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        library.refreshArticles()
                    }) {
                        Label("Refresh Feed", systemImage: "arrow.clockwise")
                    }
                    .help("Refresh Feed")
                }
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
