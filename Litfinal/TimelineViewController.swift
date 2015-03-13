//
//  TimelineViewController.swift
//  Litfinal
//
//  Created by 山口 智生 on 2015/03/08.
//  Copyright (c) 2015年 Nextvanguard. All rights reserved.
//

import UIKit
import TwitterKit

/*
tweetID
createdAt
text
author
    screenName
    name
favoriteCount
retweetCount
inReplyToTweetID
inReplyToUserID
inReplyToScreenName
permalink
isFavorited
isRetweeted
retweetID
*/

class TimelineViewController: UIViewController, UITextFieldDelegate,UIGestureRecognizerDelegate{
    var tableView: UITableView! = UITableView()
    var tweets: [TWTRTweet] = [] {
        didSet {
            tableView.reloadData()
            println("update\(count)")
            count = count + 1
        }
    }
    //var prototypeCell: TWTRTweetTableViewCell?
    var prototypeCell: OriginalTweetTableViewCell?
    
    var count:Int = 0
    
    let myButton: UIButton! = UIButton()
    let myTextField: UITextField! = UITextField()
    
    var app:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate //AppDelegateのインスタンスを取得
    
    @IBOutlet weak var navtitle: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        //tableView
        tableView.frame = CGRectMake(0,0,self.view.bounds.width, self.view.bounds.height-50)
        tableView.backgroundColor = UIColor.grayColor()
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        
        //prototypeCell = TWTRTweetTableViewCell(style: .Default, reuseIdentifier: "cell")
        prototypeCell = OriginalTweetTableViewCell(style: .Default, reuseIdentifier: "cell")
        prototypeCell?.tweetView.theme = TWTRTweetViewTheme.Dark
        prototypeCell?.delegate = self
        
        //tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.registerClass(OriginalTweetTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        // サイズを設定する.
        myButton.frame = CGRectMake(0,0,100,30)
        //myButton.backgroundColor = UIColor.whiteColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("送信", forState: UIControlState.Normal)
        myButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myButton.setTitle("済", forState: UIControlState.Highlighted)
        myButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        myButton.layer.cornerRadius = 5.0
        myButton.layer.position = CGPoint(x: self.view.frame.width-40, y:self.view.frame.height-25)
        myButton.tag = 1
        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(myButton)
        
        
        //TextField
        myTextField.frame = CGRectMake(0,0,self.view.frame.width-100,30)
        myTextField.text = ""
        myTextField.delegate = self
        myTextField.borderStyle = UITextBorderStyle.Line
        myTextField.backgroundColor = UIColor.darkGrayColor()
        myTextField.layer.position = CGPoint(x:self.view.bounds.width/2-30,y:self.view.bounds.height-25);
        myTextField.returnKeyType = UIReturnKeyType.Done
        self.view.addSubview(myTextField)
        
        
        /*let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)*/
        
        /*let swipeGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "swiped:")
        swipeGesture.delegate = self;
        //swipeGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(swipeGesture)*/
        
        navtitle.title = app.username
        
        
        count = 0

        //loadTweets()
        bu_refresh("")
        //searchTweets("モス")
        
    }
    @IBAction func bu_refresh(sender: AnyObject) {
        println("refresh")
        loadTweets()
    }
    
    func onClickMyButton(sender: UIButton){
        println("send!")
        self.performSegueWithIdentifier("tosend",sender: nil)
        /*
        sendtweet(myTextField.text + "\n\n#NextVanguard")
        myTextField.text = ""
        myTextField.resignFirstResponder()
        
        myTextField.layer.position = CGPoint(x:self.view.bounds.width/2-25,y:self.view.bounds.height-25);
        myButton.layer.position = CGPoint(x: self.view.frame.width-50, y:self.view.frame.height-25)
        */
    }
    
    
    //改行
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        myTextField.layer.position = CGPoint(x:self.view.bounds.width/2-25,y:self.view.bounds.height-25);
        myButton.layer.position = CGPoint(x: self.view.frame.width-50, y:self.view.frame.height-25)
        return true
    }
    //テキスト編集開始
    func textFieldDidBeginEditing(textField: UITextField){
        println("textFieldDidBeginEditing:" + textField.text)
        myTextField.layer.position = CGPoint(x:self.view.bounds.width/2-25,y:self.view.bounds.height-265);
        myButton.layer.position = CGPoint(x: self.view.frame.width-50, y:self.view.frame.height-265)
    }
    
    
    //再配置が必要なとき再配置(向き変化時など)
    override func viewDidLayoutSubviews() {
        myButton.layer.position = CGPoint(x: self.view.frame.width-50, y:self.view.frame.height-25)
        tableView.frame = CGRectMake(0,0,self.view.bounds.width, self.view.bounds.height-50)
        myTextField.frame = CGRectMake(0,0,self.view.frame.width-100,30)
        myTextField.layer.position = CGPoint(x:self.view.bounds.width/2-30,y:self.view.bounds.height-25);
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
    
    func loadTweets() {//Get Home Timeline
        println("load")
        TwitterAPI.getHomeTimeline({
            twttrs in
            for tweet in reverse(twttrs) {
                if self.tweets.count == 0{//最初だけ
                    self.tweets.append(tweet)
                }else{
                    if self.tweets[0].tweetID < tweet.tweetID {//前に追加
                        self.tweets.insert(tweet, atIndex: 0)
                    }else if self.tweets.last?.tweetID > tweet.tweetID {//後ろに追加
                        self.tweets.append(tweet)
                    }
                }
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
            for tweet in reverse(twttrs) {
                if self.tweets.count == 0{
                    self.tweets.append(tweet)
                }else{
                    if self.tweets[0].tweetID < tweet.tweetID {
                        self.tweets.insert(tweet, atIndex: 0)
                    }else if self.tweets.last?.tweetID > tweet.tweetID {
                        self.tweets.append(tweet)
                    }
                }
            }
            },searchword: searchword, error: {
                error in
                println(error.localizedDescription)
        })
    }
    
    func tweetView(tweetView: TWTRTweetView!, didTapURL url: NSURL!) {
        println("URL tapped")
        
        // *or* Use a system webview
        let webViewController = UIViewController()
        let webView = UIWebView(frame: webViewController.view.bounds)
        webView.loadRequest(NSURLRequest(URL: url))
        webViewController.view = webView
        self.navigationController!.pushViewController(webViewController, animated: true)
    }
}

extension TimelineViewController: OriginalTweetTableViewCellDelegate{
    func onRightSwipe(cell: OriginalTweetTableViewCell) {
        let index: Int = cell.tag
        println("onRightSwipe")
    }
    
    func onLeftSwipe(cell: OriginalTweetTableViewCell) {
        let index: Int = cell.tag
        println("onLeftSwipe")
    }
}

extension TimelineViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Num: \(indexPath.row)")
        app.replyid = tweets[indexPath.row].tweetID
        app.replyuser = tweets[indexPath.row].author.screenName
        println(tweets[indexPath.row].text)
        
        self.performSegueWithIdentifier("tosend",sender: nil)
    }
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("cell") as TWTRTweetTableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as OriginalTweetTableViewCell
        
        if tweets.count > indexPath.row {
            let tweet = tweets[indexPath.row]
            cell.tag = indexPath.row
            cell.configureWithTweet(tweet)
            cell.delegate = self
        }
        cell.tweetView.theme = TWTRTweetViewTheme.Dark
        
        
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

