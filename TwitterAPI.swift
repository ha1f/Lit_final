//
//  TwitterAPI.swift
//  Litfinal
//
//  Created by 山口 智生 on 2015/03/08.
//  Copyright (c) 2015年 Nextvanguard. All rights reserved.
//

import Foundation
import TwitterKit

class TwitterAPI {
    let baseURL = "https://api.twitter.com"
    let version = "/1.1"
    
    init() {
        
    }

    class func postTweet(tweetText: String,error: (NSError) -> ()) {
        let api = TwitterAPI()
        var clientError: NSError?
        let path = "/statuses/update.json"
        let endpoint = api.baseURL + api.version + path
        
        var param = Dictionary<String, String>()
        param["status"] = tweetText
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("POST", URL: endpoint, parameters: param, error: &clientError)
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request, completion: {
                response, data, err in
                if err == nil {
                    println("post succeeded")
                } else {
                    error(err)
                }
            })
        }
    }
    
    class func getSearch(tweets: [TWTRTweet]->(),searchword: String ,error: (NSError) -> ()) {
        let api = TwitterAPI()
        var clientError: NSError?
        let path = "/search/tweets.json"
        let endpoint = api.baseURL + api.version + path
        
        var params = Dictionary<String, String>()
        println(searchword)
        params = ["q": "time", "count":"20"]
        
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: endpoint, parameters: params, error: &clientError)
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request, completion: {
                response, data, err in
                if err == nil {
                    println("succeeded")
                    var jsonError: NSError?
                    let json: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data,
                        options: nil,
                        error: &jsonError)
                    if let jsonArray = json as? NSArray {
                        tweets(TWTRTweet.tweetsWithJSONArray(jsonArray) as [TWTRTweet])
                    }
                } else {
                    error(err)
                    println("error")
                }
            })
        }
    }
    
    class func getHomeTimeline(tweets: [TWTRTweet]->(), error: (NSError) -> ()) {
        let api = TwitterAPI()
        var clientError: NSError?
        let path = "/statuses/home_timeline.json"
        let endpoint = api.baseURL + api.version + path
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: endpoint, parameters: nil, error: &clientError)
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request, completion: {
                response, data, err in
                if err == nil {
                    var jsonError: NSError?
                    let json: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data,
                        options: nil,
                        error: &jsonError)
                    if let jsonArray = json as? NSArray {
                        tweets(TWTRTweet.tweetsWithJSONArray(jsonArray) as [TWTRTweet])
                    }
                } else {
                    error(err)
                }
            })
        }
    }
    
    class func gettweetwithid(tweets: [TWTRTweet]->(), tweetIDs: NSArray,error: (NSError) -> ()) {
        Twitter.sharedInstance().APIClient
            .loadTweetsWithIDs(tweetIDs) {
                (tweetsa, error) -> Void in
                // handle the response or error
                if let ts = tweetsa as? [TWTRTweet] {
                    tweets(ts)
                } else {
                    println("Failed to load tweets: \(error.localizedDescription)")
                }
        }
    }
    
}