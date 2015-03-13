//
//  SendViewController.swift
//  Litfinal
//
//  Created by 山口 智生 on 2015/03/08.
//  Copyright (c) 2015年 Nextvanguard. All rights reserved.
//

import UIKit
import TwitterKit

class SendViewController: UIViewController, UITextFieldDelegate {
    
    let sendButton: UIButton! = UIButton()
    let backButton: UIButton! = UIButton()
    let myTextField: UITextField! = UITextField()
    
    var app:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate //AppDelegateのインスタンスを取得
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        //送信ボタン
        sendButton.frame = CGRectMake(0,0,100,50)
        //sendButton.backgroundColor = UIColor.orangeColor()
        sendButton.layer.masksToBounds = true
        sendButton.setTitle("送信", forState: UIControlState.Normal)
        sendButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        sendButton.setTitle("了", forState: UIControlState.Highlighted)
        sendButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Highlighted)
        sendButton.layer.cornerRadius = 25.0
        sendButton.layer.position = CGPoint(x: self.view.frame.width*3/4, y:self.view.frame.height/2 + 50)
        sendButton.tag = 1
        sendButton.addTarget(self, action: "onClickSendButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(sendButton)
        
        //戻るボタン
        backButton.frame = CGRectMake(0,0,50,50)
        //backButton.backgroundColor = UIColor.redColor()
        backButton.layer.masksToBounds = true
        backButton.setTitle("←", forState: UIControlState.Normal)
        backButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        backButton.setTitle("←", forState: UIControlState.Highlighted)
        backButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Highlighted)
        backButton.layer.cornerRadius = 25.0
        backButton.layer.position = CGPoint(x: 30, y: 50)
        backButton.tag = 2
        backButton.addTarget(self, action: "onClickBackButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(backButton)
        
        //入力欄
        myTextField.frame = CGRectMake(25, 75, self.view.frame.width-50, self.view.frame.height/4)
        myTextField.backgroundColor = UIColor.grayColor()
        /*myTextField.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height-25)*/
        //myTextField.borderStyle = UITextBorderStyle.RoundedRect
        //myTextField.leftViewMode = UITextFieldViewMode.Always
        myTextField.returnKeyType = UIReturnKeyType.Done
        myTextField.text = "@" + (self.app.replyuser ?? "") + " "
        myTextField.delegate = self
        self.view.addSubview(myTextField)
        
    }
    func textFieldShouldReturn(textField: UITextField!) -> Bool{
        println( textField.text )
        textField.resignFirstResponder()
        return true
    }
    
    func onClickSendButton(sender: UIButton){
        println("send!")
        sendtweet(myTextField.text,replyid: (self.app.replyid ?? ""))
        myTextField.text = ""
        onClickBackButton(UIButton())
        
    }
    
    func onClickBackButton(sender: UIButton){
        println("back!")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendtweet(tweetText: String, replyid: String){
        TwitterAPI.postTweet(
            tweetText,
            in_reply_to_status_id: replyid,
            error: {
                error in
                println(error.localizedDescription)
        })

    }
}

