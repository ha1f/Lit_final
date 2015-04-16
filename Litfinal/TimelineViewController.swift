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
    
    var busyflag: Bool = false{
        didSet{
            if busyflag {
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
    
    var indicatorView:UIActivityIndicatorView! = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    var app:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    @IBOutlet weak var navtitle: UINavigationItem!

    var refreshControl:UIRefreshControl!
    
    var tweetData = TweetDataModel()
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navtitle.title = app.username
        self.view.backgroundColor = UIColor.blackColor()
        
        //tableViewの作成、delegate,dataSourceを設定
        tableView.frame = CGRectMake(0,0,self.view.bounds.width, self.view.bounds.height)
        tableView.backgroundColor = UIColor.darkGrayColor()
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        
        prototypeCell = OriginalTweetTableViewCell(style: .Default, reuseIdentifier: "cell")
        prototypeCell?.delegate = self
        
        tableView.registerClass(OriginalTweetTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        //indicatorのビュー
        indicatorView.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height/2)
        self.view.addSubview(indicatorView)
        
        // 引っ張ってロードする
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull-to-Refresh")
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableView:", name: "tweetLoaded", object: nil)
        
        count = 0
        
        tweetData.fetchTimeline(nil)
        
    }
    
    @objc
    func updateTableView(notification: NSNotification?){
        println("updateTableView")
        self.tableView.reloadData()
        self.busyflag=false
    }
    
    @IBAction func bu_edit(sender: AnyObject){
        onClickMyButton(UIButton())
    }
    
    func bu_refresh(sender: AnyObject) {
        println("refresh")
        tweetData.fetchTimeline(nil)
        println("test")
        //loadTweets(nil)
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
        tableView.frame = CGRectMake(0,0,self.view.bounds.width, self.view.bounds.height)
        indicatorView.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height/2)
    }
    

    
    func tweetView(tweetView: TWTRTweetView!, didTapURL url: NSURL!) {
        println("URL tapped")
        
        app.weburl = url
        
        self.performSegueWithIdentifier("viewweb",sender: nil)
    }
}

//セルに対するdelegate
extension TimelineViewController: OriginalTweetTableViewCellDelegate{
    func onRightSwipe(cell: OriginalTweetTableViewCell) {
        let index: Int = cell.tag
        println("onRightSwipe")
    }
    
    func onLeftSwipe(cell: OriginalTweetTableViewCell) {
        let index: Int = cell.tag
        println("onLeftSwipe: \(index)")
        app.replyid = tweetData.tweets[index].tweetID
        app.replyuser = tweetData.tweets[index].author.screenName
        self.performSegueWithIdentifier("tosend",sender: nil)
    }
}

//tableViewに対するdelegate
extension TimelineViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Num: \(indexPath.row)")
        app.replyid = tweetData.tweets[indexPath.row].tweetID
        app.replyuser = tweetData.tweets[indexPath.row].author.screenName
        self.performSegueWithIdentifier("tosend",sender: nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetData.tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! OriginalTweetTableViewCell
        
        if tweetData.tweets.count > indexPath.row {
            let tweet = tweetData.tweets[indexPath.row]
            cell.tag = indexPath.row
            cell.configureWithTweet(tweet)
            cell.delegate = self
            if (tweetData.tweets.count - 1) == indexPath.row{//一番下
                println("last")
                tweetData.fetchTimeline(tweetData.tweets.last?.tweetID)
            }
        }
        cell.tweetView.theme = TWTRTweetViewTheme.Dark
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tweet = tweetData.tweets[indexPath.row]
        
        prototypeCell?.configureWithTweet(tweet)
        
        let height :CGFloat! = TWTRTweetTableViewCell.heightForTweet(tweet, width: CGRectGetWidth(self.view.bounds))
        
        if height != nil{
            return height
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
}

