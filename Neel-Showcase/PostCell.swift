//
//  PostCell.swift
//  Neel-Showcase
//
//  Created by Neel Nishant on 09/10/16.
//  Copyright © 2016 Neel Nishant. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likeslbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    var post: Post!
    var req: Request?
    var likeRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.likeTapped))
       // let tap = UITapGestureRecognizer(target: self, action: Selector("likeTapped"))
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
        
        
        
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        showcaseImg.layer.cornerRadius = profileImg.frame.size.width / 2
        showcaseImg.clipsToBounds = true
    }

    func configureCell(post: Post, img: UIImage?){
        self.post = post
        
        likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        
        self.descriptionText.text = post.postDescription
        self.likeslbl.text = "\(post.likes)"
        
        if post.imageUrl != nil {
            
            if img != nil {
                self.showcaseImg.image = img
            }
            else {
                req = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { req, response, data, error in
                    
                    if error == nil {
                        let img = UIImage(data: data!)!
                        self.showcaseImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                        
                    }
                    else{
                        print(error.debugDescription)
                    }
                })
            }
        }
        else{
            self.showcaseImg.hidden = true
        }
        
       
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                //this means we have not liked this specific post
                print(snapshot.value)
                self.likeImage.image = UIImage(named: "heart-empty")
                
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        
        })
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer)
    {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                //this means we have not liked this specific post
                print(snapshot.value)
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
                
            } else {
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
            
        })
    }
    
}
