//
//  Global.swift
//  Kasa Smart
//
//  Created by Keval Patel on 3/31/19.
//  Copyright © 2019 Keval Patel. All rights reserved.
//

import Foundation
import SVProgressHUD

//MARK:- API Keys
let newsApi = "d8ba4eae71cd4545a4b080368fc5145b"
let storedArticalskey = "storedArticals"

//MARK:- APIs


//MARK:- Global Variables & Constants
let unknown = "Unknown"
var articleViewModel = [ArticleViewModel]()
var currentIndex : Int?
var qDomain = "bitcoin"
var pageIndex = 1

//MARK:- alertMessages
enum alert : String{
    case loading = "   Loading...   "
    case failedToGetData = "No more articles available"
}
// Constants
enum constants : String {
    case filter = "Filter"
    case refresh = "Refresh"
    case select = "Select"
    case Cancel = "Cancel"
    case contentNotAvailable = "Content is not available"
    case descriptionNotAvailabel = "Description is not available"
    case titleNotAvailabel = "Title is not available"
}


//MARK: - save Articles
func saveArticle(_ hashValue: Int) -> Bool{
    let userDefault = UserDefaults.standard
    var arrayHashvalue : [Int]?
    if (userDefault.value(forKey: storedArticalskey) == nil){
        arrayHashvalue = [hashValue]
        userDefault.set(arrayHashvalue, forKey: storedArticalskey)
        print(userDefault.value(forKey: storedArticalskey)!)
        return false
    }
    else{
        arrayHashvalue = userDefault.value(forKey: storedArticalskey) as? [Int]
        let isExist = arrayHashvalue?.contains(hashValue) ?? false ? true : false
        if isExist == true{
            return true
        }
        else{
            arrayHashvalue?.append(hashValue)
            userDefault.removeObject(forKey: storedArticalskey)
            userDefault.setValue(arrayHashvalue, forKey: storedArticalskey)
            print(userDefault.value(forKey: storedArticalskey)!)
            return false
        }
    }
}
//MARK: - Check Articles
func checkArticle(_ newArticle: Int) -> Bool{
    let userDefault = UserDefaults.standard
    var arrayHashvalue : [Int]?
    if (userDefault.value(forKey: storedArticalskey) == nil){
        return false
    }else{
        arrayHashvalue = userDefault.value(forKey: storedArticalskey) as? [Int]
        let isExist = arrayHashvalue?.contains(newArticle) ?? false ? true : false
        print(userDefault.value(forKey: storedArticalskey)!)
        if isExist == true{
            return true
        }
        else{
            return false
        }
    }
}
//MARK: - progressDesign
func progressDesign(){
    SVProgressHUD.setBackgroundColor(UIColor(red: 226/255, green: 226/255, blue: 226/255, alpha: 1.0))
    SVProgressHUD.setForegroundColor(UIColor.black)
    SVProgressHUD.setRingThickness(3.0)
}

