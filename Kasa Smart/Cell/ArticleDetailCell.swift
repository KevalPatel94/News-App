//
//  ArticleDetailCell.swift
//  Kasa Smart
//
//  Created by Keval Patel on 4/1/19.
//  Copyright © 2019 Keval Patel. All rights reserved.
//

import UIKit
import SVProgressHUD

class ArticleDetailCell: UICollectionViewCell {

    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgView: UIImageView!

    @IBOutlet weak var tblArticleDetail: UITableView!
    var arrayOfData : [String]!{
        didSet{
            tblArticleDetail.reloadData()
        }
    }
    var articalViewModel: ArticleViewModel!{
        didSet{
            self.imageViewProperties()
            lblAuthor.text = articalViewModel?.capitalizeString(articalViewModel?.author ?? "")
            lblDate.text = articalViewModel?.getformattedDate(articalViewModel?.publishedAt ?? "")
            arrayOfData = ["Title :  \(articalViewModel?.title ?? unknown)","Content:  \(articalViewModel?.content ?? unknown)","Description:  \(articalViewModel?.description ?? unknown)"]
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        tblArticleDetail.delegate = self as? UITableViewDelegate
        tblArticleDetail.dataSource = self
        tblArticleDetail.tableFooterView = UIView()
    }
    
    //MARK: - Dynamic View Height based on Label text
    func heightForView(_ text:String,_ font:UIFont,_ width:CGFloat,_ label:UILabel) -> CGFloat{
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    //MARK: - imageViewProperties
    func imageViewProperties(){
        imgView.sd_setImage(with: URL(string: articalViewModel?.urlToImage ?? ""), placeholderImage:UIImage(named: "PlaceHolder"), options: .refreshCached, completed: { (image, err, cache, url) in
            if image != nil{
                self.imgView.image = image
            }
        })
    }
}

//MARK: - Tableview delegate and datasource
extension ArticleDetailCell : UITabBarDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard arrayOfData?.count != nil else {
            return 0
        }
        return arrayOfData!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblArticleDetail.dequeueReusableCell(withIdentifier: "InsideCell", for: indexPath) as! InsideCell
        cell.lblData.text = arrayOfData![indexPath.row]
        return cell
}
}
