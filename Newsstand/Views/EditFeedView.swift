//
//  EditFeedView.swift
//  Newsstand
//
//  Created by Bruno Castelló on 04/08/24.
//

import SwiftUI

struct EditFeedView: View {
    @EnvironmentObject var library: Library
    @Environment(\.dismiss) var dismiss
    
    @State var feed: Feed
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("Feed Name:")
                HStack {
                    TextField("", text: $feed.name)
                        .textFieldStyle(.squareBorder)
                        .frame(minWidth: 200)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(.bottom, 8)

                Text("Feed URL:")
                HStack {
                    TextField("", text: $feed.url)
                        .textFieldStyle(.squareBorder)
                        .frame(minWidth: 200)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(.bottom, 8)

                HStack {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            
            VStack {
                Divider()
                HStack {
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Button("Save") {
                        editFeed()
                    }
                    .disabled(feed.name.isEmpty)
                    .keyboardShortcut(.defaultAction)
                }
                .padding([.top], 8)
                .padding([.leading, .trailing, .bottom])
            }
        }
        .frame(minWidth: 480, maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func editFeed() {
        errorMessage = nil
        library.edit(feed)
        dismiss()
    }
}

#Preview {
    return EditFeedView(feed: Feed())
}
