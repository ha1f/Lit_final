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

class TimelineViewController: UIViewController, TWTRTweetViewDelegate{
    var tableView: UITableView! = UITableView()
    var tweets: [TWTRTweet] = [] {
        didSet {
            tableView.reloadData()
            println("update\(count)")
            count = count + 1
        }
    }
    var busyflag: Bool = false{
        didSet{
            if busyflag == true{
                indicatorView.startAnimating()
            }else{
                indicatorView.stopAnimating()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    //var prototypeCell: TWTRTweetTableViewCell?
    var prototypeCell: OriginalTweetTableViewCell?
    
    var count:Int = 0
    
    //var maxIdStr:String = ""
    
    let myButton: UIButton! = UIButton()
    //let myTextField: UITextField! = UITextField()
    
    var indicatorView:UIActivityIndicatorView! = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    var app:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate //AppDelegateのインスタンスを取得
    
    @IBOutlet weak var navtitle: UINavigationItem!
    
    var refreshControl:UIRefreshControl!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        bu_refresh("")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navtitle.title = app.username
        self.view.backgroundColor = UIColor.blackColor()
        
        //tableView
        tableView.frame = CGRectMake(0,0,self.view.bounds.width, self.view.bounds.height)
        tableView.backgroundColor = UIColor.darkGrayColor()
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
        myButton.frame = CGRectMake(0,0,80,30)
        //myButton.backgroundColor = UIColor.whiteColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("Edit", forState: UIControlState.Normal)
        myButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myButton.setTitle("Edit", forState: UIControlState.Highlighted)
        myButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        myButton.backgroundColor = UIColor.blackColor()
        myButton.layer.position = CGPoint(x: self.view.frame.width-40, y:self.view.frame.height-25)
        myButton.tag = 1
        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(myButton)
        
        
        indicatorView.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height/2)
        self.view.addSubview(indicatorView)
        
        // 引っ張ってロードする
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull-to-Refresh")
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        count = 0
        
    }
    
    @IBAction func bu_edit(sender: AnyObject){
        onClickMyButton(UIButton())
    }
    
    func bu_refresh(sender: AnyObject) {
        println("refresh")
        loadTweets(nil)
    }
    
    func refresh(){
        println("pulled!")
        bu_refresh("")
    }
    
    func onClickMyButton(sender: UIButton){
        println("send!")
        self.app.replyid = nil
        self.app.replyuser = nil
        self.performSegueWithIdentifier("tosend",sender: nil)
    }
    
    
    //再配置が必要なとき再配置(向き変化時など)
    override func viewDidLayoutSubviews() {
        myButton.layer.position = CGPoint(x: self.view.frame.width-40, y:self.view.frame.height-25)
        tableView.frame = CGRectMake(0,0,self.view.bounds.width, self.view.bounds.height)
        indicatorView.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height/2)
    }
    
    func loadTweetsWithid(tweetIDs: NSArray) {
        self.busyflag = true
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
    
    func loadTweets(maxid: String!) {//Get Home Timeline
        self.busyflag = true
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
            self.busyflag = false
            }
            },maxid: maxid, error: {
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
                    }else if self.tweets.last?.tweetID > tweet.tweetID{
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
        println("onLeftSwipe: \(index)")
        app.replyid = tweets[index].tweetID
        app.replyuser = tweets[index].author.screenName
        self.performSegueWithIdentifier("tosend",sender: nil)
    }
}

extension TimelineViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Num: \(indexPath.row)")
        app.replyid = tweets[indexPath.row].tweetID
        app.replyuser = tweets[indexPath.row].author.screenName
        //println(tweets[indexPath.row].text)
        
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
            if (tweets.count - 1) == indexPath.row && tweets.count > 15 {//一番下
                self.loadTweets(self.tweets.last?.tweetID)
            }
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

