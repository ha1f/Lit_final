//
//  LoginViewController.swift
//  Litfinal
//
//  Created by 山口 智生 on 2015/03/08.
//  Copyright (c) 2015年 Nextvanguard. All rights reserved.
//

import UIKit
import TwitterKit


class LoginViewController: UIViewController {
    
    var myButton : UIButton! = UIButton()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        var app:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate //AppDelegateのインスタンスを取得
        // Do any additional setup after loading the view, typically from a nib.
        let logInButton = TWTRLogInButton(logInCompletion: {
            (session: TWTRSession!, error: NSError!) in
            // play with Twitter session
            if session != nil {
                println(session.userName)
                app.username = session.userName
                self.performSegueWithIdentifier("logined",sender: nil)
            }else{
                println(error.localizedDescription)
            }
        })
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
        
        
        // サイズを設定する.
        myButton.frame = CGRectMake(0,0,300,30)
        //myButton.backgroundColor = UIColor.whiteColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("Play with game", forState: UIControlState.Normal)
        myButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        myButton.setTitle("Play", forState: UIControlState.Highlighted)
        myButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        myButton.layer.cornerRadius = 5.0
        myButton.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height-25)
        myButton.tag = 1
        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(myButton)
        
        
    }
    
    func onClickMyButton(sender: AnyObject){
        println("playgame")
        self.performSegueWithIdentifier("playgame",sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

