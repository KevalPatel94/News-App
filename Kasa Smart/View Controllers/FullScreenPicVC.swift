//
//  FullScreenPicVC.swift
//  Kasa Smart
//
//  Created by Keval Patel on 4/1/19.
//  Copyright © 2019 Keval Patel. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
class FullScreenPicVC: UIViewController {

  
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var imgProfilePic: UIImageView!
    var url = ""
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show(withStatus: alert.loading.rawValue)
        setImageView()
    }
    //MARK: - setImageView
    func setImageView(){
        imgProfilePic.sd_setImage(with: URL(string:url), placeholderImage: UIImage(named: "PlaceHolder"), options: .refreshCached, completed: { (image, err, cache, url) in
            self.imgProfilePic.image = image
            SVProgressHUD.dismiss()
        })
    }
    
    //MARK: - Actions
    @IBAction func selBtnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
