//
//  ArticleCell.swift
//  Kasa Smart
//
//  Created by Keval Patel on 3/31/19.
//  Copyright © 2019 Keval Patel. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    var articalViewModel: ArticleViewModel!{
        didSet{
            lblTitle.text = articalViewModel.title
            lblAuthor.text = articalViewModel.capitalizeString(articalViewModel.author)
            lblDate.text = articalViewModel.getformattedDate(articalViewModel.publishedAt)
            lblDescription.text = articalViewModel.description

        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
