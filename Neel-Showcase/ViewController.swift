//
//  ViewController.swift
//  Neel-Showcase
//
//  Created by Neel Nishant on 03/10/16.
//  Copyright © 2016 Neel Nishant. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    @IBOutlet weak var signInButton: MaterialButton!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
            super.viewDidLoad()
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().uiDelegate = self
            
            // Uncomment to automatically sign in the user.
            GIDSignIn.sharedInstance().signInSilently()
            
            // TODO(developer) Configure the sign-in button look/feel
            // ...
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    func authenticateWithGoogle(sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        
    }
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
        
        FIRAuth.auth()!.signInWithCredential(credential) { (user, error) in
            if error != nil {
                print("login failed\(error)")
            }
            else {
                let userData = ["provider": credential.provider]
                DataService.ds.createFirebaseUser(user!.uid, user: userData)
                NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                
            }
        }
    }
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
    }
    @IBAction func logInBtnPressed(sender: UIButton!)
    {
        if let mail = emailField.text where mail != "", let pwd = passwordField.text where pwd != ""
        {
            FIRAuth.auth()!.signInWithEmail(mail, password: pwd, completion: { (authData, error) in
                if error != nil{
                    
                    print(error)
                    print(error!.code)
                    
                    if error!.code == STATUS_ACCOUNT_NONEXIST {
                        FIRAuth.auth()!.createUserWithEmail(mail, password: pwd, completion: { (result, error) in
                            
                            if error != nil {
                                self.showErrorAlert("Could not create Account", msg: "Problem creating account. Try something else")
                            }
                            else {
                                
                                
                                
                                
                                NSUserDefaults.standardUserDefaults().setValue(result!.uid, forKey: KEY_UID)
                                FIRAuth.auth()?.signInWithEmail(mail, password: pwd, completion: { (authData, error) in
                                    let user = ["provider": (authData?.providerID)!, "blah": "test"]
                                    DataService.ds.createFirebaseUser((authData?.uid)!, user: user)
                                })
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                        })
                    }
                    else{
                        self.showErrorAlert("Could not log in", msg: "Please check your username or password")
                    }
                }
                else{
                   FIRAuth.auth()!.signInWithEmail(mail, password: pwd, completion: { (authData, error) in
                     NSUserDefaults.standardUserDefaults().setValue(authData!.uid, forKey: KEY_UID)
                    
                    
                   })
                   
                    
                   
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
            
            
     
        }
        else{
            showErrorAlert("Email and Password Required", msg: "You must enter an email and a password")
        }
        
    }
    
    func showErrorAlert(title: String, msg: String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
 
    @IBAction func googleSignInBtnPressed(sender: AnyObject) {
        
        
        authenticateWithGoogle(signInButton)
       
        
        
        
    }
    
    
}

