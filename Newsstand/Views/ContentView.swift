//
//  ContentView.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var library: Library

    let sidebarWidth: CGFloat = 272
    let feedWidth: CGFloat = 350

    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: sidebarWidth, ideal: sidebarWidth, max: .infinity)
        } content: {
            FeedView()
                .navigationSplitViewColumnWidth(min: feedWidth, ideal: feedWidth, max: .infinity)
        } detail: {
            ArticleView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        }
        .navigationSubtitle(library.selectedFeed?.name ?? "")
        .sheet(item: $library.addFeed) { feed in
            AddFeedView(feed: feed)
        }
        .sheet(item: $library.editFeed) { feed in
            EditFeedView(feed: feed)
        }
    }
}

#Preview {
    return ContentView()
        .environmentObject(Library())
}
