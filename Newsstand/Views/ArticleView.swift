//
//  ArticleView.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import SwiftUI

struct ArticleView: View {
    @EnvironmentObject var library: Library
    
    let article: Article?

    var body: some View {
        Group {
            if let article = article {
                WebView(
                    url: URL(string: "about:blank")!,
                    htmlContent: generateHTMLContent(for: article)
                )
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
        
            a { 
                color: \(isDarkMode ? "#FF9F00" : "#FF9500");
                text-decoration: none;
            }
            
            h1, h2, h3, h4, h5, h6, 
            .h1, .h2, .h3, .h4, .h5, .h6 {
                font-weight: 600;
            }
            
            .secondary { 
                color: \(isDarkMode ? "#98989D" : "#8E8E93");
                font-weight: 500;
                margin-bottom: 10px;
            }
            
            .categories { 
                color: \(isDarkMode ? "#FF9F00" : "#FF9500");
                font-size: 12px;
                font-weight: normal;
                margin-bottom: 10px;
                text-transform: uppercase;
            }
            
            img { 
                height: auto;
                margin-bottom: 20px;
                max-width: 100%;
                width: 100%;
            }
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
                <p class="small secondary mt-2">View original: <a href="\(article.link)">\(article.link)</a></p>
                <hr>
                <p class="categories"><b>\(categoriesString)</b></p>
            </body>
        </html>
        """
        
        return htmlContent
    }
}

#Preview {
    let sampleArticle = Article(
        title: "Here's to the crazy ones",
        description: "<p>The round pegs in the square holes. The ones who see things differently. They're not fond of rules. And they have no respect for the status quo. You can quote them, disagree with them, glorify or vilify them. About the only thing you can't do is ignore them. Because they change things. They push the human race forward. And while some may see them as the crazy ones, we see genius. Because the people who are crazy enough to think they can change the world, are the ones who do.</p>",
        link: "https://apple.com",
        pubDate: "Thu, 22 Feb 2024 12:00:00 +0000",
        creator: "Steve Jobs",
        categories: ["Apple", "Steve Jobs"]
    )

    return ArticleView(
        article: sampleArticle
    )
}
