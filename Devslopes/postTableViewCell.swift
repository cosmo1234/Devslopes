//
//  postTableViewCell.swift
//  Devslopes
//
//  Created by sagaya Abdulhafeez on 14/04/2016.
//  Copyright © 2016 sagaya Abdulhafeez. All rights reserved.
//

import UIKit
import Alamofire

class postTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showCaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesText: UILabel!
    
    var post:Post!
    
    var request:Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        showCaseImg.clipsToBounds = true
    }
    
    
    func configureCell(post:Post, img:UIImage?){
        self.post = post
        self.descriptionText.text = post.postDescription
        self.likesText.text = "\(post.likes)"
        
        if post.imageUrl != nil{
            
            if img != nil{
                //LOAD THE IMAGE FROM THE CACHE
                self.showCaseImg.image = img
            }else{
                
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { (request, response, data, error) in
                    
                    
                    if error == nil{
                        let img = UIImage(data: data!)!
                        self.showCaseImg.image = img
                        //ADD TO CACHE
                        
                        feedViewController.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    }
                    
                    
                })
            }
            
        }else{
            self.showCaseImg.hidden = true
        }
        
    }
    

}
