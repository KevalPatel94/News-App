//
//  NewsSummaryVC.swift
//  Kasa Smart
//
//  Created by Keval Patel on 3/31/19.
//  Copyright © 2019 Keval Patel. All rights reserved.
//

import UIKit
import SVProgressHUD

class NewsSummaryVC: UIViewController {
   
    @IBOutlet weak var tblNewsArticles: UITableView!
    var alertView: UIAlertController?
    var pickerView: UIPickerView?
    var filterArray : [String]?
    var isFetchingData = false
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        filterArray = ["bitcoin","apple","Microsoft"]
        progressDesign()
        setUpNavigationBar()
        tableViewProperties()
        getData(filterArray?[0] ?? "bitcoin", changeDate(startDate: Date(), value: -1),pageIndex)
    }
    //MARK: - getData BY calling Web Service
    fileprivate func getData(_ titel: String, _ date: String,_ page: Int) {
        isFetchingData = true
        WebService.shared.fetchArticles(titel, date, page) { (articles, err) in

            if let err = err {
                self.isFetchingData = false
                DispatchQueue.main.async {
                    SVProgressHUD.showInfo(withStatus: err.localizedDescription)
                }
                return
            }
            guard articles != nil else{
                return
            }
            for art in articles!{
                articleViewModel.append(ArticleViewModel(article: art))
            }
            if articleViewModel.count > 0{
                DispatchQueue.main.async {
                    self.isFetchingData = false
                    self.tblNewsArticles.reloadData()
                    if pageIndex == 1{
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.tblNewsArticles.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    //MARK: - setUpNavigationBar
    func setUpNavigationBar() {
         let rightItem = UIBarButtonItem(title: constants.filter.rawValue, style: .plain, target: self, action: #selector(filterArticals))
        navigationItem.rightBarButtonItem = rightItem
        let leftItme = UIBarButtonItem(title: constants.refresh.rawValue, style: .plain, target: self, action: #selector(refreshArticals))
        navigationItem.leftBarButtonItem = leftItme
    }
    @objc func filterArticals(){
        constructAlertView("Select Filter")
    }
    @objc func refreshArticals(){
        if articleViewModel.count >= 1 {
            pageIndex = pageIndex + 1
        }
        self.getData(qDomain, self.changeDate(startDate: Date(), value: -1), pageIndex)
    }
    //MARK: - tableViewProperties
    func tableViewProperties(){
        tblNewsArticles.delegate = self
        tblNewsArticles.dataSource = self
        tblNewsArticles.estimatedRowHeight = 136
        tblNewsArticles.rowHeight = UITableView.automaticDimension
        tblNewsArticles.tableFooterView = UIView()
    }
    //MARK: - changeDate
    func changeDate(startDate : Date, value : Int) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let newDateDate = Calendar.current.date(byAdding: Calendar.Component.day, value: value, to: startDate) else{
            return ""
        }
        return dateFormatter.string(from: newDateDate)
    }
    //MARK:- Construct AlertView
    func constructAlertView(_ title: String){
        alertView = UIAlertController(
            title: title,
            message: "\n\n\n\n\n\n\n\n\n",
            preferredStyle: .actionSheet)
        
        // Add alert Action
        let action = UIAlertAction(title: constants.select.rawValue, style: UIAlertAction.Style.default) { (action) in
            pageIndex = 1
            articleViewModel.removeAll()
            self.view.endEditing(true)
            self.getData(qDomain, self.changeDate(startDate: Date(), value: -1),pageIndex)
        }
        let anotheraction = UIAlertAction(title: constants.Cancel.rawValue, style: UIAlertAction.Style.cancel) { (action) in
            
        }
        alertView?.addAction(action)
        alertView?.addAction(anotheraction)
        // Add Picker View
        pickerView = UIPickerView(frame:
            CGRect(x: 0, y: 50, width: 260, height: 162))
        pickerView?.dataSource = self
        pickerView?.delegate = self
        alertView?.view.addSubview(pickerView!)
        // Present Alert
        self.present(alertView!, animated: true) {
            self.pickerView?.frame.size.width = (self.alertView?.view.frame.size.width)!
        }
        
    }
}


//MARK: - tableView Delegate and DataSource
extension NewsSummaryVC : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return articleViewModel.count
        }
        else if section == 1 && isFetchingData{
            return 1
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0{
            let cell = tblNewsArticles.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as? ArticleCell
            
            if checkArticles(articleViewModel[indexPath.row], storedArticalskey)
            { cell?.backgroundColor = UIColor(red: 226/255, green: 226/255, blue: 226/255, alpha: 1.0) }
            else{
                cell?.backgroundColor = UIColor.white
            }
            cell?.articalViewModel = articleViewModel[indexPath.row]
            return cell!
    }
    //Note: - We can also use will display cell rather than scrollViewDidScroll
  /*  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == articleViewModel.count - 1 else {
            return
        }
        guard isFetchingData == false else {
            return
        }
        isFetchingData = true
        pageIndex = pageIndex + 1
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.tblNewsArticles.reloadSections(IndexSet(integer: 1), with: .automatic)
            self.getData(qDomain, self.changeDate(startDate: Date(), value: -1), pageIndex)
        }
    }*/
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetY = scrollView.contentOffset.y
        let contenHeight = scrollView.contentSize.height
        if offSetY > contenHeight - scrollView.frame.height{
            if !isFetchingData{
                isFetchingData = true
                pageIndex = pageIndex + 1
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.getData(qDomain, self.changeDate(startDate: Date(), value: -1), pageIndex)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let destVC = self.storyboard?.instantiateViewController(withIdentifier: "ArticleDetailVC") as? ArticleDetailVC{
            checkAndSaveArticles(articleViewModel[indexPath.row], storedArticalskey)
            currentIndex = indexPath.row
            destVC.refreshArticleListDelegate = self
            self.navigationController?.pushViewController(destVC, animated: true)
        }
    }
}


//MARK: - PickerView Delegate
extension NewsSummaryVC: UIPickerViewDataSource,UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filterArray?.count ?? 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return "\(String(describing: filterArray?[row]))"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        qDomain = filterArray?[row] ?? ""
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = filterArray?[row]
        return pickerLabel!
    }
}


//MARK: - Saving and Checking on Local
extension NewsSummaryVC{
    func saveArticles(_ articles: [ArticleViewModel],_ KeyForUserDefaults: String) {
        let data = articles.map { try? JSONEncoder().encode($0) }
        UserDefaults.standard.removeObject(forKey: KeyForUserDefaults)
        UserDefaults.standard.set(data, forKey: KeyForUserDefaults)
    }
    func getArticles(_ KeyForUserDefaults: String) -> [ArticleViewModel] {
        guard let encodedData = UserDefaults.standard.array(forKey: KeyForUserDefaults) as? [Data] else {
            return []
        }
        return encodedData.map { try! JSONDecoder().decode(ArticleViewModel.self, from: $0) }
    }
    func checkAndSaveArticles(_ articleViewModel: ArticleViewModel,_ KeyForUserDefaults: String){
        var articles : [ArticleViewModel]?
        guard UserDefaults.standard.value(forKey: KeyForUserDefaults) != nil else {
            articles = [articleViewModel]
            saveArticles(articles!, KeyForUserDefaults)
            return
        }
        articles = getArticles(KeyForUserDefaults)
        if !(articles?.contains(articleViewModel))!{
            articles?.append(articleViewModel)
            saveArticles(articles!, KeyForUserDefaults)
        }
    }
    func checkArticles(_ articleViewModel: ArticleViewModel,_ KeyForUserDefaults: String) -> Bool{
        var articles : [ArticleViewModel]?
        articles = getArticles(KeyForUserDefaults)
        return (articles?.contains(articleViewModel))!

    }
}


extension NewsSummaryVC : RefreshArticleListDelegate{
    func refreshArticleList() {
        tblNewsArticles.reloadData()
        guard currentIndex != nil else {
            return
        }
        let indexPath = IndexPath(row: currentIndex!, section: 0)
        tblNewsArticles.scrollToRow(at: indexPath, at: .middle, animated: false)
    }
}
