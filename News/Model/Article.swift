//
//  Article.swift
//  Article
//
//  Created by Adnann Muratovic on 01.09.25.
//

import Foundation

/*
{
    "id": 7,
    "title": "Meta Launches New VR Headset",
    "subtitle": "Lighter, cheaper, more immersive",
    "author": "Emily White",
    "category": "Tech",
    "date": "2025-04-05",
    "image": "https://images.unsplash.com/photo-1635070041078-e363dbe005cb?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
    "text": "Meta introduced its latest VR headset, boasting improved ergonomics and a reduced price point. Gamers and developers welcomed the update enthusiastically."
}
*/

struct Articles: Decodable {
    let articles: [Article]
}

struct Article: Decodable, Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let author: String
    let category: String
    let date: String
    let image: URL?
    let text: String
}
