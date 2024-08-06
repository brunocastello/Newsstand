//
//  SidebarView.swift
//  Newsstand
//
//  Created by Bruno Castelló on 04/08/24.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var library: Library

    var body: some View {
        List {
            Section {
                ForEach(library.feeds) { feed in
                    NavigationLink {
                        FeedView(feed: feed)
                            .navigationSplitViewColumnWidth(min: library.feedWidth, ideal: library.feedWidth, max: .infinity)
                    } label: {
                        HStack {
                            Image(systemName: "dot.radiowaves.up.forward")
                                .resizable()
                                .frame(width: 16, height: 16)
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
                            library.delete(feed: feed)
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    library.addFeed = Feed()
                }) {
                    Label("Add Feed", systemImage: "plus")
                }
                .help("Add Feed")
            }
        }
    }
}

#Preview {
    return SidebarView()
        .environmentObject(Library())
}
