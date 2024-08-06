//
//  ContentView.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var library: Library

    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: library.sidebarWidth, ideal: library.sidebarWidth, max: .infinity)
        } content: {
            Text("Select a feed")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        } detail: {
            Text("Select an article")
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)
                .padding()
        }
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
