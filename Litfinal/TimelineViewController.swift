//
//  ViewController.swift
//  Litfinal
//
//  Created by 山口 智生 on 2015/03/08.
//  Copyright (c) 2015年 Nextvanguard. All rights reserved.
//

import UIKit
import TwitterKit

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView!
    var tweets: [TWTRTweet] = [] {
        didSet {
            tableView.reloadData()
            println("update\(count)")
            count = count + 1
        }
    }
    var prototypeCell: TWTRTweetTableViewCell?
    
    var refreshControl :UIRefreshControl!
    
    var count:Int = 0
    
    let myButton: UIButton! = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blueColor()
        
        // サイズを設定する.
        myButton.frame = CGRectMake(0,0,50,50)
        myButton.backgroundColor = UIColor.redColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("書", forState: UIControlState.Normal)
        myButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myButton.setTitle("移", forState: UIControlState.Highlighted)
        myButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        myButton.layer.cornerRadius = 25.0
        myButton.layer.position = CGPoint(x: self.view.frame.width/4, y:self.view.frame.height-25)
        myButton.tag = 1
        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(myButton)
        
        
        println("loaded")
        tableView = UITableView(frame: CGRectMake(0,0,self.view.bounds.width, self.view.bounds.height-50))
        tableView.delegate = self
        tableView.dataSource = self
        
        prototypeCell = TWTRTweetTableViewCell(style: .Default, reuseIdentifier: "cell")
        
        // Use custom colors
        //prototypeCell!.textLabel?.textColor = UIColor.yellowColor()
        //prototypeCell!.backgroundColor = UIColor.blueColor()
        
        tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("loadTweets"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        count = 0
        
        loadTweets()
        //loadTweetsWithid(["20", "510908133917487104"])
    }
    func onClickMyButton(sender: UIButton){
        println("send!")
        self.performSegueWithIdentifier("tosend",sender: nil)
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
        self.refreshControl?.endRefreshing()
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

