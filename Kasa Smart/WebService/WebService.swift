//
//  WebService.swift
//  Kasa Smart
//
//  Created by Keval Patel on 3/31/19.
//  Copyright © 2019 Keval Patel. All rights reserved.
//

import Foundation
import SVProgressHUD
class WebService: NSObject {
    static let shared = WebService()
    func fetchArticles(_ title: String,_ date: String,_ page: Int,completion: @escaping ([ArticleModel]?, Error?) -> ()) {
        print(page)
        DispatchQueue.main.async {
            SVProgressHUD.show(withStatus: alert.loading.rawValue)
        }
        let urlString = "https://newsapi.org/v2/everything?q=\(title)&sortBy=publishedAt&page=\(page)&apiKey=\(newsApi)"
        print(urlString)
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            if let err = err {
                completion(nil, err)
                if pageIndex >= 2{
                    pageIndex = pageIndex - 1
                }
                SVProgressHUD.showInfo(withStatus: err.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    data, options: []) as! [String:AnyObject]
                guard jsonResponse["articles"] != nil  else{
                    completion(nil, err)
                    if pageIndex >= 2{
                        pageIndex = pageIndex - 1
                    }
                    SVProgressHUD.showInfo(withStatus: alert.failedToGetData.rawValue)
                    return
                }
                var articles = [ArticleModel]()
                for article in jsonResponse["articles"]! as? Array<Dictionary<String,AnyObject>> ?? [[:]]{
                    let source = article["source"] as? [String:String] ?? ["":""]
                    let id = source["id"] ?? ""
                    let name = source["name"] ?? ""
                    let article = ArticleModel(id: id, name: name, author: article["author"] as? String ?? "", source: source, title: article["title"] as? String ?? constants.titleNotAvailabel.rawValue, description: article["description"] as? String ?? constants.descriptionNotAvailabel.rawValue, url: article["url"] as? String ?? "", urlToImage: article["urlToImage"] as? String ?? "", publishedAt: article["publishedAt"] as? String ?? "", content: article["content"] as? String ?? constants.contentNotAvailable.rawValue)
                    articles.append(article)
                }
                DispatchQueue.main.async {
                    completion(articles, nil)
                }
            } catch let jsonErr {
                SVProgressHUD.showInfo(withStatus: jsonErr.localizedDescription)
            }
            }.resume()
    }
}
