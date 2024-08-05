//
//  NewsstandApp.swift
//  Newsstand
//
//  Created by Bruno Castelló on 03/08/24.
//

import SwiftUI

@main
struct NewsstandApp: App {
    
    @StateObject var library = Library()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(library)
        }
    }
}
