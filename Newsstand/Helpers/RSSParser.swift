//
//  RSSParser.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import Foundation
import Combine

class RSSParser: NSObject, XMLParserDelegate {
    private var parser: XMLParser
    private var currentElement = ""
    private var articles: [Article] = []
    private var currentTitle = ""
    private var currentDescription = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentCreator = ""
    private var currentCategories: [String] = []

    private var completion: ((Result<[Article], Error>) -> Void)?

    init(data: Data, completion: @escaping (Result<[Article], Error>) -> Void) {
        self.parser = XMLParser(data: data)
        self.completion = completion
        super.init()
        self.parser.delegate = self
    }
    
    func parse() {
        parser.parse()
    }
    
    // MARK: - XMLParserDelegate Methods
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "item" {
            currentTitle = ""
            currentDescription = ""
            currentLink = ""
            currentPubDate = ""
            currentCreator = ""
            currentCategories = []
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let article = Article(
                title: currentTitle,
                description: currentDescription,
                link: currentLink,
                pubDate: currentPubDate,
                creator: currentCreator,
                categories: currentCategories.isEmpty ? nil : currentCategories
            )
            articles.append(article)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanString = trimmedString.replacingOccurrences(of: "\u{FFFD}", with: "") // Remove replacement character
        
        switch currentElement {
        case "title":
            currentTitle += cleanString
        case "description":
            currentDescription += cleanString
        case "link":
            currentLink += cleanString
        case "pubDate":
            currentPubDate += cleanString
        case "creator":
            currentCreator += cleanString
        case "category":
            if !cleanString.isEmpty {
                currentCategories.append(cleanString)
            }
        default:
            break
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        completion?(.success(articles))
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        completion?(.failure(parseError))
    }
    
    static func fetchArticles(from url: String) -> AnyPublisher<[Article], URLError> {
        guard let url = URL(string: url) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .flatMap { data in
                Future<[Article], URLError> { promise in
                    let parser = RSSParser(data: data) { result in
                        switch result {
                        case .success(let articles):
                            promise(.success(articles))
                        case .failure(let error):
                            promise(.failure(error as? URLError ?? URLError(.unknown)))
                        }
                    }
                    parser.parse()
                }
            }
            .eraseToAnyPublisher()
    }
}
