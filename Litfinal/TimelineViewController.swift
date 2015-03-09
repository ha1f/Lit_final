//
//  ViewController.swift
//  Litfinal
//
//  Created by 山口 智生 on 2015/03/08.
//  Copyright (c) 2015年 Nextvanguard. All rights reserved.
//

import UIKit
import TwitterKit

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , UITextFieldDelegate,UIGestureRecognizerDelegate{
    var tableView: UITableView!
    var tweets: [TWTRTweet] = [] {
        didSet {
            tableView.reloadData()
            println("update\(count)")
            count = count + 1
        }
    }
    var prototypeCell: TWTRTweetTableViewCell?
    
    var count:Int = 0
    
    let myButton: UIButton! = UIButton()
    let myTextField: UITextField! = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        //tableView
        tableView = UITableView(frame: CGRectMake(0,0,self.view.bounds.width, self.view.bounds.height-50))
        tableView.delegate = self
        tableView.dataSource = self
        
        prototypeCell = TWTRTweetTableViewCell(style: .Default, reuseIdentifier: "cell")
        
        tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        // サイズを設定する.
        myButton.frame = CGRectMake(0,0,60,30)
        myButton.backgroundColor = UIColor.whiteColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("送信", forState: UIControlState.Normal)
        myButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        myButton.setTitle("済", forState: UIControlState.Highlighted)
        myButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        myButton.layer.cornerRadius = 5.0
        myButton.layer.position = CGPoint(x: self.view.frame.width-35, y:self.view.frame.height-25)
        myButton.tag = 1
        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(myButton)
        
        
        //TextField
        myTextField.frame = CGRectMake(0,0,self.view.frame.width-100,30)
        myTextField.text = ""
        myTextField.delegate = self
        myTextField.borderStyle = UITextBorderStyle.RoundedRect
        myTextField.layer.position = CGPoint(x:self.view.bounds.width/2-35,y:self.view.bounds.height-25);
        self.view.addSubview(myTextField)
        
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        
        let swipeGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "swiped:")
        swipeGesture.delegate = self;
        //swipeGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(swipeGesture)
        
        
        
        count = 0
        
        
        //loadTweets()
        searchTweets("#NextVanguard")
        //loadTweetsWithid(["20", "510908133917487104"])
    }
    // タップイベント.
    func tapped(sender: UITapGestureRecognizer){
        println("tapped")
        if (myTextField.isFirstResponder()) {
            myTextField.resignFirstResponder()
            myTextField.layer.position = CGPoint(x:self.view.bounds.width/2-25,y:self.view.bounds.height-25);
            myButton.layer.position = CGPoint(x: self.view.frame.width-50, y:self.view.frame.height-25)
        }
    }
    
    
    func onClickMyButton(sender: UIButton){
        println("send!")
        //self.performSegueWithIdentifier("tosend",sender: nil)
        sendtweet(myTextField.text + "\n#NextVanguard")
        myTextField.text = ""
        myTextField.resignFirstResponder()
        
        myTextField.layer.position = CGPoint(x:self.view.bounds.width/2-25,y:self.view.bounds.height-25);
        myButton.layer.position = CGPoint(x: self.view.frame.width-50, y:self.view.frame.height-25)
        
    }
    
    
    //改行
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        myTextField.layer.position = CGPoint(x:self.view.bounds.width/2-25,y:self.view.bounds.height-25);
        myButton.layer.position = CGPoint(x: self.view.frame.width-50, y:self.view.frame.height-25)
        return true
    }
    //編集開始
    func textFieldDidBeginEditing(textField: UITextField){
        println("textFieldDidBeginEditing:" + textField.text)
        myTextField.layer.position = CGPoint(x:self.view.bounds.width/2-25,y:self.view.bounds.height-265);
        myButton.layer.position = CGPoint(x: self.view.frame.width-50, y:self.view.frame.height-265)
    }
    
    
    //再配置が必要なとき(向き変化時など)
    override func viewDidLayoutSubviews() {
        myButton.layer.position = CGPoint(x: self.view.frame.width-50, y:self.view.frame.height-25)
        tableView.frame = CGRectMake(0,0,self.view.bounds.width, self.view.bounds.height-50)
        myTextField.frame = CGRectMake(0,0,self.view.frame.width-100,30)
        myTextField.layer.position = CGPoint(x:self.view.bounds.width/2-25,y:self.view.bounds.height-25);
    }
    
    //ツイート送信
    func sendtweet(tweetText: String){
        TwitterAPI.postTweet(
            tweetText,
            error: {
                error in
                println(error.localizedDescription)
        })
        
    }
    
    func loadTweetsWithid(tweetIDs: NSArray) {
        TwitterAPI.gettweetwithid({
            twttrs in
            for tweet in twttrs {
                self.tweets.append(tweet)
            }
            },tweetIDs: tweetIDs,
            error: {
                error in
                println(error.localizedDescription)
        })
    }
    
    func loadTweets() {
        println("load")
        TwitterAPI.getHomeTimeline({
            twttrs in
            for tweet in twttrs {
                self.tweets.append(tweet)
            }
            }, error: {
                error in
                println(error.localizedDescription)
        })
    }
    
    func searchTweets(searchword: String) {
        println("search")
        TwitterAPI.getSearch({
            twttrs in
            for tweet in twttrs {
                self.tweets.append(tweet)
            }
            },searchword: searchword, error: {
                error in
                println(error.localizedDescription)
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as TWTRTweetTableViewCell
        
        let tweet = tweets[indexPath.row]
        cell.configureWithTweet(tweet)
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tweet = tweets[indexPath.row]
        
        prototypeCell?.configureWithTweet(tweet)
        
        let height :CGFloat! = TWTRTweetTableViewCell.heightForTweet(tweet, width: CGRectGetWidth(self.view.bounds))
        
        if height != nil{
            return height
        } else {
            return tableView.estimatedRowHeight
        }
    }
}

