//
//  ViewController.swift
//  Devslopes
//
//  Created by sagaya Abdulhafeez on 13/04/2016.
//  Copyright © 2016 sagaya Abdulhafeez. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit


class ViewController: UIViewController {

    @IBOutlet weak var emailField: MaterialTextField!
    @IBOutlet weak var passwordField: MaterialTextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    override func viewDidAppear(animated: Bool) {
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil{
            self.performSegueWithIdentifier(LOGGED_IN, sender: nil)
        }
    }
    

    
    @IBAction func fbBtnPressed(sender: AnyObject) {
        
        let facebookLogin = FBSDKLoginManager()
        //SET PERMISSIONS
        facebookLogin.logInWithReadPermissions(["email"]) { (facebookResult: FBSDKLoginManagerLoginResult!,error: NSError!) in
            
            //IF ERROR
            if error != nil{
                print("FACEBOOK LOGIN FAILED \(error)")
            }else{
                
                //IF NO ERROR LOGGED IN
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                //DATASERVICE PROVIDES THE BASE URL AND ALL
                //TRYING TO SAVE THE FACEBOOK USER TO FIREBASE
                Dataservice.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { (error, data) in
                    
                    if error != nil{
                        print("Login Failed!")
                    }else{
                        print("Logged in \(data))")
                        
                        //save user to firebase
                        
                        let user = ["provider": data.provider!, "blah":"test"]
                        
                        Dataservice.ds.createFirebaseUser(data.uid, user: user)
                        
                        
                        
                        NSUserDefaults.standardUserDefaults().setValue(data.uid, forKey: KEY_UID)
                        
                        self.performSegueWithIdentifier(LOGGED_IN, sender: nil)
                    }
                    
                })
                
            }
            
        }
        
    }
    
    
    
    
    
    
    
    @IBAction func login(sender: AnyObject) {
        
        if let email = emailField.text where email != "", let passwd = passwordField.text where passwd != ""{
            //Performing login
            Dataservice.ds.REF_BASE.authUser(email, password: passwd, withCompletionBlock: { (error, data) in
                //IF ERROR ON LOGIN REGISTER :)
                if error != nil{
                    print(error)
                    //WOW AWESOME WE ARE CHECKING IF THE ERROR CODE IS -8 WHICH IS ACCOUNT NOT EXIST IF IT IS EQUAL THEN CREATE NEW USER
                    if error.code == STATUS_ACCOUNT_NONEXIST{
                        Dataservice.ds.REF_BASE.createUser(email, password: passwd, withValueCompletionBlock: { (error, result) in
                            
                            if error != nil{
                                self.showErrowAlert("Could not create account", msg: "Problem create account try something else")
                            }else{
                                //Result is a dictionary!
                                NSUserDefaults.standardUserDefaults().setValue(result["uid"], forKey: KEY_UID)
                                
                                
                                //NOW LOGIN
                                Dataservice.ds.REF_BASE.authUser(email, password: passwd, withCompletionBlock: { (error, data) in
                                    
                                    let user = ["provider": data.provider!, "blah":"emailTestr"]
                                    
                                    Dataservice.ds.createFirebaseUser(data.uid, user: user)

                                })
                                self.performSegueWithIdentifier(LOGGED_IN, sender: nil)
                            }
                        })
                    }else{
                        self.showErrowAlert("Could not login", msg: "Please check your Username or password")
                    }
                    
                    
                }else{
                    self.performSegueWithIdentifier(LOGGED_IN, sender: nil)
                }
                
            })
            
        }else{
            showErrowAlert("Email and Password required", msg: "You must enter an email and password")
        }
        
    }
    
    

    func showErrowAlert(title:String, msg:String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}

