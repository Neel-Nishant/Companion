//
//  FeedVC.swift
//  Neel-Showcase
//
//  Created by Neel Nishant on 09/10/16.
//  Copyright © 2016 Neel Nishant. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSectorImage: UIImageView!
    var posts = [Post]()
    var imageSelected = false
    var imagePicker: UIImagePickerController!
    static var imageCache = NSCache()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tView.delegate = self
        tView.dataSource = self
        tView.estimatedRowHeight = 345
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: {snapshot in
            print(snapshot.value)
            
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tView.reloadData()
        })

        
    }

 
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        
        if let cell = tView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            cell.req?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageUrl {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img: img)
            return cell
        }
        else {
            return PostCell()
        }
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        if post.imageUrl == nil {
            return 150
        }
        else {
            return tView.estimatedRowHeight
        }
        
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSectorImage.image = image
        imageSelected = true
    }
    
    @IBAction func selectImage(sender: AnyObject) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    @IBAction func makePost(sender: AnyObject) {
        if let txt = postField.text where txt != "" {
            if let img = imageSectorImage.image where imageSelected == true {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)
                
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)
                
                Alamofire.upload(.POST, url, multipartFormData: { (MultipartFormData) in
                    MultipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    MultipartFormData.appendBodyPart(data: keyData!, name: "key")
                    MultipartFormData.appendBodyPart(data: keyJSON!, name: "format")
                    
                })  { encodingResult in
                    
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON(completionHandler: { response in
                            if let info = response.result.value as? Dictionary<String, AnyObject> {
                                if let links = info["links"] as? Dictionary<String, AnyObject> {
                                    if let imgLink = links["image_link"] as? String {
                                        print("LINK: \(imgLink)")
                                        self.postToFirebase(imgLink)
                                    }
                                }
                            }
                        })
                      
                    case .Failure(let error):
                        print(error)
                    }
                }
            }
            else{
                self.postToFirebase(nil)
            }
        }
    }
    
    func postToFirebase(imgUrl: String?)
    {
        var post: Dictionary<String, AnyObject> = [
            "description": postField.text!,
            "likes": 0
        ]
        if imgUrl != nil {
            post["imageurl"] = imgUrl!
        }
        
        let fireBasePost = DataService.ds.REF_POSTS.childByAutoId()
        fireBasePost.setValue(post)
        
        postField.text = ""
        imageSectorImage.image = UIImage(named: "camera")
        imageSelected = false
        tView.reloadData()
    }
    
    
}







