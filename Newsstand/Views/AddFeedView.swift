//
//  AddFeedView.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import SwiftUI

struct AddFeedView: View {
    @EnvironmentObject var library: Library
    @Environment(\.dismiss) var dismiss
    
    @State var feed: Feed

    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("Feed:")
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
                    
                    Button("Add Feed") {
                        addFeed()
                    }
                    .disabled(feed.url.isEmpty)
                    .keyboardShortcut(.defaultAction)
                }
                .padding([.top], 8)
                .padding([.leading, .trailing, .bottom])
            }
        }
        .frame(minWidth: 480, maxWidth: .infinity, maxHeight: .infinity)
    }

    private func addFeed() {
        guard !feed.url.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        fetchFeedName(from: feed.url) { result in
            switch result {
            case .success(let name):
                let newFeed = Feed(name: name, url: feed.url)
                library.add(newFeed)
                dismiss()
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }

    private func fetchFeedName(from url: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let feedURL = URL(string: url) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: feedURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let xmlString = String(data: data, encoding: .utf8),
                  let name = extractFeedName(from: xmlString) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to parse feed"])))
                return
            }
            
            completion(.success(name))
        }
        .resume()
    }

    private func extractFeedName(from xmlString: String) -> String? {
        let regex = try? NSRegularExpression(pattern: "<title>(.*?)</title>", options: [])
        let matches = regex?.matches(in: xmlString, options: [], range: NSRange(location: 0, length: xmlString.utf16.count))
        return matches?.first.flatMap {
            let range = Range($0.range(at: 1), in: xmlString)
            return range.flatMap { String(xmlString[$0]) }
        }
    }
}

#Preview {
    let sampleFeed = Feed(
        id: UUID(),
        name: "",
        url: ""
    )
    
    return AddFeedView(feed: sampleFeed)
}
