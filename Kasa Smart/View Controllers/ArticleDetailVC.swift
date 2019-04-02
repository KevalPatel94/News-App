//
//  ArtcleDetailVC.swift
//  Kasa Smart
//
//  Created by Keval Patel on 4/1/19.
//  Copyright © 2019 Keval Patel. All rights reserved.
//

import UIKit
import SVProgressHUD
protocol RefreshArticleListDelegate{
    func refreshArticleList()
}
class ArticleDetailVC: UIViewController{

    @IBOutlet weak var colArticleDetails: UICollectionView!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    var pageindexPath: IndexPath?
    var refreshArticleListDelegate : RefreshArticleListDelegate?
    var isFetchingData = false

    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show(withStatus: alert.loading.rawValue)
        collectionViewProperties()
        pageIndexPathSetup()
        setUpNavigationBar()
    }
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        colArticleDetails.collectionViewLayout.invalidateLayout()
        guard  currentIndex != nil else {
            return
        }
        pageindexPath = IndexPath(item: currentIndex!, section: 0)
        DispatchQueue.main.async {
            self.colArticleDetails.scrollToItem(at: self.pageindexPath! , at: .centeredHorizontally, animated: true)
        }
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
                    self.colArticleDetails.reloadData()
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    func setUpNavigationBar() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        let leftItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(selBtnBack(_:)))
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    //MARK: - collectionViewProperties
    func collectionViewProperties(){
        colArticleDetails.delegate = self
        colArticleDetails.dataSource = self
        colArticleDetails.isPagingEnabled = true
        colArticleDetails.isScrollEnabled = false
        colArticleDetails.isHidden = true
        pageControl.isUserInteractionEnabled = false
    }
    
    //MARK: - pageIndexPathSetup
    func pageIndexPathSetup(){
        guard currentIndex != nil else {
            return
        }
        pageindexPath = IndexPath(item: currentIndex!, section: 0)
        if currentIndex! >= 21{
            pageControl.isHidden = true
        }
        if pageindexPath != nil{
            pageControl.currentPage = currentIndex!
            pageControl.numberOfPages = articleViewModel.count
            pageControl.size(forNumberOfPages: articleViewModel.count)
            DispatchQueue.main.async {
                self.colArticleDetails.scrollToItem(at: self.pageindexPath! , at: .centeredHorizontally, animated: false)
                self.colArticleDetails.isHidden = false
                SVProgressHUD.dismiss()
            }
        }
        SVProgressHUD.dismiss()
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
    
    //MARK: - Actions
    @IBAction func selBtnPrevious(_ sender: Any) {
        guard  currentIndex != nil else {
            return
        }
        guard currentIndex! - 1 >= 0 else {
            return
        }
        currentIndex = currentIndex! - 1
        checkAndSaveArticles(articleViewModel[currentIndex!], storedArticalskey)
        pageindexPath = IndexPath(item: currentIndex!, section: 0)
        if pageindexPath != nil{
            pageControl.currentPage = currentIndex!
            colArticleDetails.scrollToItem(at: pageindexPath! , at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func selBtnNext(_ sender: Any) {
        guard  currentIndex != nil else {
            return
        }
        guard currentIndex! + 1 <= articleViewModel.count - 1 else {
            currentIndex = currentIndex! + 1
            self.getData(qDomain, self.changeDate(startDate: Date(), value: -1),pageIndex)
            colArticleDetails.scrollToItem(at: pageindexPath! , at: .centeredHorizontally, animated: true)

            return
        }
        currentIndex = currentIndex! + 1
        checkAndSaveArticles(articleViewModel[currentIndex!], storedArticalskey)
        pageindexPath = IndexPath(item: currentIndex!, section: 0)
        if pageindexPath != nil{
            pageControl.currentPage = currentIndex!
            colArticleDetails.scrollToItem(at: pageindexPath! , at: .centeredHorizontally, animated: true)
        }
    }
    
   
    @IBAction func selBtnFullScreenImage(_ sender: Any) {
        guard currentIndex != nil else {
            return
        }
        guard currentIndex! <= articleViewModel.count - 1  else {
            return
        }
        if let destVC = self.storyboard?.instantiateViewController(withIdentifier: "FullScreenPicVC") as? FullScreenPicVC{
            destVC.url = articleViewModel[currentIndex!].urlToImage
            self.navigationController?.present(destVC, animated: true, completion: nil)
        }
    }
    @IBAction func selBtnBack(_ sender: Any){
        refreshArticleListDelegate?.refreshArticleList()
        self.navigationController?.popViewController(animated: true)
    }
}

extension ArticleDetailVC : UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articleViewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colArticleDetails.dequeueReusableCell(withReuseIdentifier: "ArticleDetailCell", for: indexPath) as? ArticleDetailCell
        cell?.articalViewModel = articleViewModel[indexPath.row]
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:view.frame.size.width, height: view.frame.size.height - 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        currentIndex = Int(x/view.frame.width)
        guard currentIndex! <= articleViewModel.count - 1 && currentIndex! >= 0 else {
            return
        }
        pageindexPath = IndexPath(item: currentIndex!, section: 0)
        if pageindexPath != nil{
            pageControl.currentPage = currentIndex!
            colArticleDetails.scrollToItem(at: pageindexPath! , at: .centeredHorizontally, animated: true)
        }
    }
    
}

//MARK: - Saving and Checking on Local
extension ArticleDetailVC{
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
