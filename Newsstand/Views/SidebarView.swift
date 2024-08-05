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
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        List(selection: $library.selectedFeed) {
            Section {
                ForEach(library.feeds) { feed in
                    NavigationLink(
                        value: feed
                    ) {
                        HStack {
                            Image(systemName: "dot.radiowaves.up.forward")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(library.selectedFeed == feed ? .white : .accentColor)
                            Text(feed.name)
                                .truncationMode(.tail)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .contextMenu {
                        Button(action: {
                            library.editFeed = feed
                        }) {
                            Text("Edit Feed")
                        }
                        Divider()
                        Button(action: {
                            if let index = library.feeds.firstIndex(of: feed) {
                                library.delete(at: IndexSet(integer: index))
                                if library.selectedFeed == feed {
                                    library.selectedFeed = nil
                                    library.selectedArticle = nil
                                }
                            }
                        }) {
                            Text("Delete Feed")
                        }
                    }
                }
                .onMove { indices, newOffset in
                    library.move(fromOffsets: indices, toOffset: newOffset)
                }
            } header: {
                Text("Feeds")
                    .padding(.vertical, 4)
            }
            .collapsible(false)
        }
        .onChange(of: library.selectedFeed) {
            if let feed = library.selectedFeed {
                RSSParser.fetchArticles(from: feed.url)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            // Implement logic for fail in fetching articles
                            print("Failed to fetch articles: \(error)")
                        }
                    }, receiveValue: { articles in
                        library.articles = articles
                    })
                    .store(in: &cancellables)
            } else {
                library.articles = []
            }
        }
    }
}

#Preview {
    return SidebarView()
        .environmentObject(Library())
}
