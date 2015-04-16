//
//  TweetDataModel.swift
//  Litfinal
//
//  Created by 山口 智生 on 2015/04/16.
//  Copyright (c) 2015年 Nextvanguard. All rights reserved.
//

import Foundation
import TwitterKit

class TweetDataModel :NSObject{
    
    var tweets:[TWTRTweet]
    
    // initialize
    override init() {
        //super.init()
        self.tweets = []
    }
    
    func getData(Void)->[TWTRTweet] {
        return self.tweets
    }
    
    func fetchTimeline(maxid:String?){
        TwitterAPI.getHomeTimeline({
            twttrs in
            
            println("fetch")
            
            if self.tweets.count == 0 {
                self.tweets = twttrs
            }else{
                let tmptweets:[TWTRTweet]
                
                if twttrs[0].tweetID > self.tweets.last?.tweetID {//新しいツイートがある
                    tmptweets = reverse(twttrs)
                }else{
                //if twttrs.last?.tweetID < self.tweets[0].tweetID{//古いツイートがある
                    tmptweets=twttrs
                }
            
                for tweetCell in tmptweets {
                    if tweetCell.tweetID > self.tweets.last?.tweetID {//新ツイートを上に追加
                        self.tweets.insert(tweetCell,atIndex: 0)
                    }else if tweetCell.tweetID < self.tweets[0].tweetID {//古いツイートを下に追加
                        self.tweets.append(tweetCell)
                    }
                }
            }
            println("finish")
            
            NSNotificationCenter.defaultCenter().postNotificationName("tweetLoaded", object: nil)
            
            },
            maxid: maxid,
            error: {error in println(error.localizedDescription) })
    }
}