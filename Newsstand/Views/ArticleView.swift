//
//  ArticleView.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import SwiftUI
import WebKit

struct ArticleView: View {
    @EnvironmentObject var library: Library
    
    let article: Article?

    var body: some View {
        Group {
            if let article = article {
                WebView(url: URL(string: "about:blank")!, htmlContent: generateHTMLContent(for: article))
                    .edgesIgnoringSafeArea(.all)
            } else if library.selectedFeed != nil {
                Text("Select an article")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }

    private func generateHTMLContent(for article: Article) -> String {
        let appearance = NSAppearance.currentDrawing()
        let isDarkMode = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        
        let css = """
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
        <style>
        body {
            background-color: transparent;
            color: \(isDarkMode ? "white" : "black");
            padding: 16px;
        }
        a { color: \(isDarkMode ? "#FF9F00" : "#FF9500"); text-decoration: none; }
        h1, h2, h3, h4, h5, h6, .h1, .h2, .h3, .h4, .h5, .h6 { font-weight: 600; }
        .secondary { color: \(isDarkMode ? "#98989D" : "#8E8E93"); margin-bottom: 10px; font-weight: 500; }
        .categories { font-size: 12px; font-weight: normal; color: \(isDarkMode ? "#FF9F00" : "#FF9500"); margin-bottom: 10px; text-transform: uppercase; }
        img { max-width: 100%; height: auto; width: 100%; }
        </style>
        """
        
        let categoriesString = article.categories?.joined(separator: ", ") ?? ""
        let creatorText = article.creator.isEmpty ? "" : "by \(article.creator)"
        let pubDateText = "\(article.pubDate) \(creatorText)"
        
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        \(css)
        </head>
        <body>
        <p class="small secondary">\(pubDateText)</p>
        <h1 class="h3">\(article.title)</h1>
        \(article.description)
        <hr>
        <p class="categories"><b>\(categoriesString)</b></p>
        </body>
        </html>
        """
        
        return htmlContent
    }
}

struct WebView: NSViewRepresentable {
    let url: URL
    let htmlContent: String

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlContent, baseURL: url)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }
    }
}

#Preview {
    let sampleArticle = Article(
        title: "Sample Article Title",
        description: "<p>This is a sample article description.</p>",
        link: "https://example.com",
        pubDate: "Fri, 02 Aug 2024 12:13:21 +0000",
        creator: "Sample Creator",
        categories: ["Category1", "Category2"]
    )

    return ArticleView(
        article: sampleArticle
    )
}
