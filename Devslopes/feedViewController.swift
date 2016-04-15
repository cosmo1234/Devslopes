//
//  feedViewController.swift
//  Devslopes
//
//  Created by sagaya Abdulhafeez on 14/04/2016.
//  Copyright © 2016 sagaya Abdulhafeez. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class feedViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var posts = [Post]()
    
    @IBOutlet weak var postField: MaterialTextField!
    
    var imageSelected = false
    
    var imagePicker:UIImagePickerController!
    
    @IBOutlet weak var cameraImg: UIImageView!
   static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 304
        
        //LISTEN WHEN A VALUE IS CHANGED
        Dataservice.ds.REF_POST.observeEventType(.Value, withBlock: { snapShot in
                //print(snapShot.value)
            if let snapshots = snapShot.children.allObjects as? [FDataSnapshot]{
                
                self.posts = [] //empty the array
                for snap in snapshots{
                   // print(snap)
                    
                    if let postDict = snap.value as? Dictionary <String,AnyObject>{
                        let key = snap.key //which is the first key or parent key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                    
                }
                
            }
            self.tableView.reloadData()
        })
        
    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? postTableViewCell{
            
            cell.request?.cancel() //have no idea why this is there but i guess to cancel request :)
            
            //CACHING IMAGE
            
            var img: UIImage?
            //GET THE IMAGE DATA FROM CACHE WITH KEY OF IMAGEURL
            if let url = post.imageUrl{
               img = feedViewController.imageCache.objectForKey(url) as? UIImage
                
            }
            
            cell.configureCell(post,img: img)
            
            
            return cell
        }else{
            return postTableViewCell()
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        if post.imageUrl == nil{
            return 200
        }else{
              return  tableView.estimatedRowHeight
        }
    }
    
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func postBtn(sender: AnyObject) {
        
        if let txt = postField.text where txt != ""{
            if let img = cameraImg.image where  imageSelected == true{
                let urlString = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlString)!
                //compress image
                let imageData = UIImageJPEGRepresentation(img, 0.2)!
                //BECAUSE ALOMOFIRE REQUIRES DATA
                let keyData = "567CFJKL4672078bf3b07f1f5438f0c82c5c91ee".dataUsingEncoding(NSUTF8StringEncoding)!//convert string to data
                let keyjson = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    //THIS WILL UPLOAD
                    //UPLOAD ALL THIS DATA
                    multipartFormData.appendBodyPart(data: imageData, name:"fileupload", fileName:"image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyjson, name: "format")
                    
                }) { encodingResult in
                    //THIS WILL SHOW RESULT
                    
                    
                    switch encodingResult {
                        //switch result case it is successful and create the upload constatnt that has the data
                    case .Success(let upload, _, _):
                        //Read the json data and get the image link from it
                        upload.responseJSON(completionHandler: {result in
                            if let info = result.result.value as? Dictionary<String, AnyObject> {
                                
                                if let links = info["links"] as? Dictionary<String, AnyObject> {
                                    print(links)
                                    if let imgLink = links["image_link"] as? String {
                                        self.postToFirebase(imgLink)
                                        
                                    }
                                }
                            }
                        })
                        
                    case .Failure(let error):
                        print(error)
                        //Maybe show alert to user and let them try again
                    }
                }
                
            }else{
                self.postToFirebase(nil)
            }
            
        }
        
    }
    
    
    func postToFirebase(imageUrl:String?){
        
        var post: Dictionary<String,AnyObject> = [
            "description": postField.text!,
            "totalLikes": 0
        ]
        
        if imageUrl != nil{
            post["image_url"] = imageUrl!
        }
        
        let firebasePost = Dataservice.ds.REF_POST.childByAutoId() //generates an autoid 
        
        firebasePost.setValue(post) //post dictionary top!
        
        postField.text = ""
        cameraImg.image = UIImage(named: "camera")
        imageSelected = false
        tableView.reloadData()
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        
        cameraImg.image = image
        imageSelected = true
    }
    

}
