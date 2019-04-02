//
//  ArticleViewModel.swift
//  Kasa Smart
//
//  Created by Keval Patel on 3/31/19.
//  Copyright © 2019 Keval Patel. All rights reserved.
//

import Foundation
struct ArticleViewModel: Hashable, Codable{
    
    let id : String
    let name : String
    let author : String
    let source : Dictionary<String,String>
    let title : String
    let description : String
    let url : String
    let urlToImage : String
    let publishedAt : String
    let content : String
    


    init(article: ArticleModel){
        self.id = article.id != "" ? article.author : " "
        self.name = article.name != "" ? article.name : " "
        self.source = article.source
        self.author = article.author != "" ? article.author : unknown
        self.title = article.title != "" ? article.title : " "
        self.description = article.description != "" ? article.description : unknown
        self.url = article.url != "" ? article.url : unknown
        self.urlToImage = article.urlToImage != "" ? article.urlToImage : " "
        self.publishedAt = article.publishedAt != "" ? article.publishedAt : " "
        self.content = article.content != "" ? article.content : " "
    }

    //MARK: - capitalizeString
    func capitalizeString(_ inputString: String) -> String {
        return inputString.uppercased()
    }
    
    //MARK: - getformattedDate
    func getformattedDate(_ dateInString: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let index = dateInString.index(dateInString.endIndex, offsetBy: -11)
        if let date = dateFormatter.date(from: "\(dateInString[...index])"){
            dateFormatter.dateStyle = .long
            return dateFormatter.string(from: date)
        }else{
            return unknown
        }
    }
    static func ==(lhs: ArticleViewModel , rhs: ArticleViewModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.author == rhs.author && lhs.title == rhs.title && lhs.description == rhs.description && lhs.source == rhs.source && lhs.publishedAt == rhs.publishedAt && lhs.content == rhs.content
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(author)
        hasher.combine(title)
        hasher.combine(description)
        hasher.combine(source)
        hasher.combine(publishedAt)
        hasher.combine(content)

    }
}
